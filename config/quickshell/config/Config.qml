pragma Singleton

import QtCore
import Quickshell
import Quickshell.Io

import "root:/config/loaders"


Singleton {
  id: root

  // Paths
  readonly property string homePath: `${StandardPaths.writableLocation(StandardPaths.HomeLocation)}`

  readonly property string dataPath: `${StandardPaths.writableLocation(StandardPaths.GenericDataLocation)}/system`
  readonly property string statePath: `${StandardPaths.writableLocation(StandardPaths.GenericStateLocation)}/system`
  readonly property string cachePath: `${StandardPaths.writableLocation(StandardPaths.GenericCacheLocation)}/system`
  readonly property string configPath: `${StandardPaths.writableLocation(StandardPaths.GenericConfigLocation)}/system`


  // Configurations
  property alias lock: adapter.lock


  // Configurations loader
  FileView {
    path: `${root.configPath}/config.json`
    watchChanges: true

    onFileChanged: this.reload()
    onAdapterUpdated: this.writeAdapter()

    JsonAdapter {
      id: adapter

      property JsonObject lock: Lock {}
    }
  }
}

