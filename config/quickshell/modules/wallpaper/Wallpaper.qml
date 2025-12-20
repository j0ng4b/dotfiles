import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import qs.config

Variants {
  model: Quickshell.screens
  delegate: PanelWindow {
    id: wallpaperWindow
    required property var modelData
    screen: modelData

    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: Config.appName + '-wallpaper'

    anchors {
      top: true
      left: true
      right: true
      bottom: true
    }

    // Main wallpaper image
    Image {
      id: wallpaper
      anchors.fill: parent

      fillMode: Image.PreserveAspectCrop
      antialiasing: true
      asynchronous: true
      retainWhileLoading: true
      source: ''

      Component.onCompleted: {
        source = Config.wallpaper.source

        Config.wallpaper.onSourceChanged.connect(() => {
          // The wallpaper source can change before the current wallpaper is
          // loaded, for example when the shell starts the source is set to the
          // default wallpaper path but later the user config is loaded and the
          // source is changed to the user's wallpaper.
          //
          // In this case we just set the source directly without animation.
          if (status != Image.Ready) {
            source = Config.wallpaper.source
            return
          }

          if (animationWallpaperChange.running)
            animationWallpaperChange.complete()

          animationLayer.source = Config.wallpaper.source
        })

        animationLayer.statusChanged.connect(() => {
          if (animationLayer.status != Image.Ready)
            return

          animationMask.centerX = Math.random() * wallpaperWindow.screen.width;
          animationMask.centerY = Math.random() * wallpaperWindow.screen.height;

          animationWallpaperChange.start()
        })

        animationWallpaperChange.finished.connect(() => {
          wallpaper.source = animationLayer.source
          animationLayer.source = ''
        })
      }
    }


    // Animation layer for wallpaper transitions
    Image {
      id: animationLayer
      anchors.fill: parent
      fillMode: Image.PreserveAspectCrop
      antialiasing: true
      asynchronous: true
      source: ''
      visible: false
    }

    MultiEffect {
      source: animationLayer
      anchors.fill: animationLayer

      maskEnabled: true
      maskSource: animationMask
    }

    Item {
      id: animationMask
      anchors.fill: animationLayer
      layer.enabled: true
      visible: false

      Shape {
        anchors.fill: parent

        ShapePath {
          PathAngleArc {
            centerX: animationMask.centerX
            centerY: animationMask.centerY
            radiusX: animationMask.radius
            radiusY: animationMask.radius
            startAngle: 0
            sweepAngle: 360
          }
        }
      }

      property real radius: 0
      property real centerX: 0
      property real centerY: 0
    }

    NumberAnimation {
      id: animationWallpaperChange
      target: animationMask
      property: 'radius'
      from: 0
      to: Math.sqrt(Math.pow(wallpaperWindow.width, 2) + Math.pow(wallpaperWindow.height, 2))
      duration: 1500
      easing.type: Easing.InSine
    }
  }
}

