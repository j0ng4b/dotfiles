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
  property bool editingClock: false

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


  Item {
    id: clockContainer

    property int padding: 20
    property real scaleFactor: Config.lockscreen.clock.scale

    readonly property real maxScaleFactor: 3.5
    readonly property real minScaleFactor: 0.5

    width: content.implicitWidth + padding * 2
    height: content.implicitHeight + padding * 2

    x: {
      if (Config.lockscreen.clock.pos.x >= 0)
        return Config.lockscreen.clock.pos.x;

      return parent.width / 2 - width / 2
    }

    y: {
      if (Config.lockscreen.clock.pos.y >= 0)
        return Config.lockscreen.clock.pos.y;

      return 100
    }

    NumberAnimation on opacity {
      duration: 900
      easing.type: Easing.Linear
      running: root.unlocking
      from: 1
      to: 0
    }

    Behavior on x {
      NumberAnimation {
        duration: 300
        easing.type: Easing.OutCubic
      }
    }

    Behavior on y {
      NumberAnimation {
        duration: 300
        easing.type: Easing.OutCubic
      }
    }

    Behavior on scaleFactor {
      NumberAnimation {
        duration: 300
        easing.type: Easing.OutCubic
      }
    }

    Rectangle {
      anchors.fill: parent
      color: 'transparent'

      border.color: root.editingClock ? Colorscheme.current.primary : 'transparent'
      border.width: root.editingClock ? 4 : 0
      radius: 20
    }

    Column {
      id: content
      anchors.centerIn: parent

      Label {
        id: clock

        anchors.horizontalCenter: parent.horizontalCenter

        color: Colorscheme.current.primary
        renderType: Text.NativeRendering
        font.pointSize: 90 * clockContainer.scaleFactor
        text: Clock.time
      }

      Label {
        id: date
        anchors.horizontalCenter: parent.horizontalCenter

        color: Colorscheme.current.secondary
        renderType: Text.NativeRendering
        font.pointSize: 30 * clockContainer.scaleFactor
        text: Clock.date
      }
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      drag.target: root.editingClock ? clockContainer : null
      drag.axis: Drag.XAndYAxis
      acceptedButtons: Qt.LeftButton
      cursorShape: {
        if (!root.editingClock)
          return Qt.ArrowCursor;

        if (pressed)
          return Qt.ClosedHandCursor;

        return Qt.OpenHandCursor;
      }

      onDoubleClicked: root.editingClock = !root.editingClock;
      onReleased: {
        Config.lockscreen.clock.pos.x = Math.floor(clockContainer.x);
        Config.lockscreen.clock.pos.y = Math.floor(clockContainer.y);
      }
    }

    Rectangle {
      width: 12
      anchors {
        right: parent.right
        top: parent.top
        bottom: parent.bottom
      }
      visible: root.editingClock
      color: 'transparent'

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.SizeHorCursor

        property real startX

        onPressed: startX = mouseX
        onReleased: Config.lockscreen.clock.scale = clockContainer.scaleFactor
        onPositionChanged: {
          const dx = mouseX - startX;

          clockContainer.scaleFactor = Math.min(
            clockContainer.maxScaleFactor,
            Math.max(clockContainer.minScaleFactor, clockContainer.scaleFactor + dx / 300));
        }
      }
    }

    Rectangle {
      height: 12
      anchors {
        right: parent.right
        left: parent.left
        bottom: parent.bottom
      }
      visible: root.editingClock
      color: 'transparent'

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.SizeVerCursor

        property real startY

        onPressed: startY = mouseY
        onReleased: Config.lockscreen.clock.scale = clockContainer.scaleFactor
        onPositionChanged: {
          const dy = mouseY - startY;

          clockContainer.scaleFactor = Math.min(
            clockContainer.maxScaleFactor,
            Math.max(clockContainer.minScaleFactor, clockContainer.scaleFactor + dy / 300));
        }
      }
    }

    Rectangle {
      width: 16
      height: 16
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      visible: root.editingClock
      color: 'transparent'

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.SizeFDiagCursor

        property real startX
        property real startY

        onPressed: {
          startX = mouseX
          startY = mouseY
        }
        onReleased: Config.lockscreen.clock.scale = clockContainer.scaleFactor
        onPositionChanged: {
          const dx = mouseX - startX;
          const dy = mouseY - startY;

          const delta = (dx + dy) / 2;

          clockContainer.scaleFactor = Math.min(
            clockContainer.maxScaleFactor,
            Math.max(clockContainer.minScaleFactor, clockContainer.scaleFactor + delta / 300));
        }
      }
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

    NumberAnimation on opacity {
      duration: 900
      easing.type: Easing.Linear
      running: root.unlocking
      from: 1
      to: 0
    }
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
