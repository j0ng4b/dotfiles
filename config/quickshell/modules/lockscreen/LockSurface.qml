pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Controls.Fusion
import Quickshell.Wayland

import qs.config
import qs.services


Rectangle {
	id: root

  required property WlSessionLock lock
	required property LockContext context

  property bool unlocking: false

  Component.onCompleted: {
    let self = root;

    context.failedUnlock.connect(() => {
      self.unlocking = false;
    });

    context.unlocked.connect(() => {
      self.unlocking = true;
    });
  }

  Image {
    id: wallpaper
    anchors.fill: parent

    fillMode: Image.PreserveAspectCrop
    antialiasing: true
    asynchronous: true
    retainWhileLoading: true
    source: Config.wallpaper.source

    layer.enabled: true
    layer.effect: MultiEffect {
      id: wallpaperBlur

      autoPaddingEnabled: false
      blurEnabled: true

      NumberAnimation {
        target: wallpaperBlur
        running: true
        property: 'blur'

        duration: 1000
        easing.type: Easing.Linear
        from: 0
        to: 0.8
      }

      NumberAnimation {
        target: wallpaperBlur
        property: 'blur'
        duration: 800
        running: root.unlocking
        easing.type: Easing.Linear
        to: 0
      }
    }
  }

  Column {
    anchors {
      horizontalCenter: parent.horizontalCenter
      top: parent.top
      topMargin: 100
    }

    Label {
      id: clock

      anchors.horizontalCenter: parent.horizontalCenter

      color: Colorscheme.current.primary
      renderType: Text.NativeRendering
      font.pointSize: 90
      text: Clock.time
    }

    Label {
      id: date
      anchors.horizontalCenter: parent.horizontalCenter

      color: Colorscheme.current.secondary
      renderType: Text.NativeRendering
      font.pointSize: 30
      text: Clock.date
    }
  }

  Item {
    clip: true
    anchors.centerIn: parent

    height: passwordMask.contentHeight
    width: root.context.unlockInProgress ? 0 : passwordMask.contentWidth

    Behavior on width {
      NumberAnimation {
        duration: 150
        easing.type: Easing.Linear
      }
    }

    Text {
      id: passwordMask

      anchors.centerIn: parent
      color: Colorscheme.current.primary
      layer.enabled: true
      renderType: Text.NativeRendering
      font.pointSize: 300
      font.family: 'monospace'
      font.letterSpacing: -80
      rightPadding: Math.abs(font.letterSpacing)
      text: root.context.maskedText
    }
  }

  Image {
    id: wallpaperForeground
    anchors.fill: parent

    visible: Config.wallpaper.layered && !Config.wallpaperGeneratingFg
    fillMode: Image.PreserveAspectCrop
    antialiasing: true
    asynchronous: true
    retainWhileLoading: true
    source: Config.wallpaper.foreground

    layer.enabled: true
    layer.smooth: true
  }

  Rectangle {
    id: inputRect

    anchors.centerIn: parent
    clip: true
    focus: true
    width: 50
    height: 50
    radius: 25

    color: {
      if (root.context.showFailure)
        return Colorscheme.current.error;

      if (root.unlocking)
        return Colorscheme.current.primary;

      return Colorscheme.current.surface;
    }

    Behavior on color {
      ColorAnimation {
        duration: 300
      }
    }


    Keys.onPressed: kevent => {
      if (root.context.unlockInProgress)
        return;

      if (kevent.key === Qt.Key_Enter || kevent.key === Qt.Key_Return) {
        root.context.tryUnlock();
        return;
      }

      if (kevent.key === Qt.Key_Backspace) {
        if (kevent.modifiers & Qt.ControlModifier) {
          root.context.currentText = '';
          return;
        }

        root.context.currentText = root.context.currentText.slice(0, -1);
        return;
      }

      if (kevent.text)
        root.context.currentText += kevent.text;
    }

    Text {
      id: lockIcon
      anchors.centerIn: parent

      transform: Translate {
        id: shakeTransform
        x: 0
      }

      color: {
        if (root.context.showFailure)
          return Colorscheme.current.on_error;

        if (root.unlocking)
          return Colorscheme.current.on_primary;

        return Colorscheme.current.on_surface;
      }

      font.family: 'Material Symbols Rounded Filled'
      font.hintingPreference: Font.PreferFullHinting
      font.pointSize: 18
      antialiasing: true
      renderType: Text.NativeRendering
      text: root.unlocking ? 'lock_open_right' : 'lock'

      Behavior on color {
        ColorAnimation {
          duration: 300
        }
      }

      Behavior on rotation {
        NumberAnimation {
          duration: 300
          easing.type: Easing.Linear
        }
      }

      SequentialAnimation {
        id: shakeAnimation
        loops: 1

        NumberAnimation {
          target: shakeTransform
          property: 'x'
          duration: 50
          from: 0
          to: -10
        }

        NumberAnimation {
          target: shakeTransform
          property: 'x'
          duration: 50
          from: -10
          to: 5
        }

        NumberAnimation {
          target: shakeTransform
          property: 'x'
          duration: 100
          from: 5
          to: -10
        }

        NumberAnimation {
          target: shakeTransform
          property: 'x'
          duration: 100
          from: -10
          to: 0
        }
      }

      Timer {
        interval: 500
        running: root.context.showFailure
        repeat: false

        onTriggered: shakeAnimation.restart();
      }

      Timer {
        interval: 300
        repeat: true
        running: root.context.unlockInProgress
        triggeredOnStart: true

        onRunningChanged: {
          if (lockIcon.rotation < 180)
            lockIcon.rotation = 360;
          else
            lockIcon.rotation = 0;
        }

        onTriggered: lockIcon.rotation += 50;
      }
    }
  }

  Timer {
    interval: 1000
    running: root.unlocking
    onTriggered: root.lock.locked = false;
  }
}
