pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  readonly property string appName: 'ohmyshell'

  readonly property string configPath: Paths.config + '/' + appName
  readonly property string cachePath: Paths.cache + '/' + appName

  readonly property alias colors: adapter.colors

  readonly property alias wallpaper: adapter.wallpaper
  readonly property alias wallpaperGeneratingFg: wallpaperFgGenerator.running



  FileView {
    path: root.configPath + '/config.json'
    watchChanges: true

    onAdapterUpdated: this.writeAdapter()
    onFileChanged: this.reload()
    onLoadFailed: err => {
      if (err == FileViewError.FileNotFound)
        this.writeAdapter()
    }

    adapter: JsonAdapter {
      id: adapter

      property JsonObject colors: JsonObject {
        // Enable dynamic color scheme based on wallpaper colors.
        property bool dynamic: true

        // This option specifies the color scheme mode
        //
        // Possible values are:
        //     'light' - Use light color scheme
        //     'dark' - Use dark color scheme
        property string scheme: 'dark'
      }

      property JsonObject wallpaper: JsonObject {
        // This option enables support for layered wallpapers.
        //
        // Layered wallpapers split the background and foreground elements into
        // different layers, allowing for more dynamic and visually appealing.
        //
        // When enabled, the wallpaper system will generate the foreground from
        // wallpaper and render it on a separate layer above the background.
        property bool layered: true

        // Path to the wallpaper image
        //
        // Note: this is now empty to force wallpaper foreground generation
        // even on startup.
        property string source

        // Path to wallpaper foreground image
        property string foreground

        // Restart generators if needed when wallpaper source changes
        onSourceChanged: {
          if (source !== '' && colors.dynamic && !colorsGenerator.running) {
            colorsGenerator.wallpaperSource = source
            colorsGenerator.running = true
          }

          if (source !== '' && layered && !wallpaperFgGenerator.running) {
            wallpaperFgGenerator.wallpaperSource = source
            wallpaperFgGenerator.running = true
          }
        }
      }

      property JsonObject lockscreen: JsonObject {
        property JsonObject clock: JsonObject {
          // Position of the clock on the lock screen
          property JsonObject pos: JsonObject {
            property real x: -1
            property real y: -1
          }
        }
      }
    }
  }

  Process {
    id: colorsGenerator
    property string wallpaperSource

    command: [
      Paths.url2Path(Qt.resolvedUrl('../scripts/colorsGenerator')),
      Paths.url2Path(wallpaperSource),
      Paths.url2Path(root.configPath + '/colors.json'),
      Paths.url2Path(root.cachePath)
    ]
  }

  Process {
    id: wallpaperFgGenerator
    property string wallpaperSource

    command: [
      Paths.url2Path(Qt.resolvedUrl('../scripts/rembg')),
      Paths.url2Path(wallpaperSource),
      Paths.url2Path(root.cachePath)
    ]

    stdout: StdioCollector {
      onStreamFinished: {
        let text = this.text.trim()

        if (text === '')
          return

        if (text.startsWith('Error: ')) {
          console.warn('Failed to generate wallpaper foreground:', text.substring(7))
          return
        }

        root.wallpaper.foreground = text;
      }
    }
  }
}

