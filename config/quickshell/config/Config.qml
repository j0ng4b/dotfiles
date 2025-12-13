pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  readonly property string appName: 'ohmyshell'
  readonly property string configPath: Paths.config + '/' + appName
  readonly property string cachePath: Paths.cache + '/' + appName

  FileView {
    path: root.configPath + '/config.json'
    watchChanges: true

    onAdapterUpdated: this.writeAdapter()
    onFileChanged: this.reload()
    onLoadFailed: err => {
      if (err == FileViewError.FileNotFound)
        this.writeAdapter()
    }

    JsonAdapter {
      id: adapter

      property string wallpaperPath: root.configPath + '/wallpaper'
    }
  }
}

