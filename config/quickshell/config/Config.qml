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
        property string source: root.configPath + '/wallpaper'

        // Restart generators if needed when wallpaper source changes
        onSourceChanged: {
          if (source !== '' && colors.dynamic && !colorsGenerator.running)
              colorsGenerator.running = true

          if (source !== '' && layered && !wallpaperFgGenerator.running)
              wallpaperFgGenerator.running = true
        }
      }
    }
  }

  Process {
    id: colorsGenerator

    command: [
      Paths.url2Path(Qt.resolvedUrl('../scripts/colorsGenerator')),
      Paths.url2Path(root.wallpaper.source),
      Paths.url2Path(root.configPath + '/colors.json')
    ]
  }

  Process {
    id: wallpaperFgGenerator

    command: [
      Paths.url2Path(Qt.resolvedUrl('../scripts/rembg')),
      Paths.url2Path(root.wallpaper.source),
      Paths.url2Path(root.cachePath)
    ]

    stdout: StdioCollector {
      onStreamFinished: {
        // Todo: set a property with foreground wallpaper path
      }
    }
  }
}

