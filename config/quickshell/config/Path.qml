pragma Singleton

import Quickshell
import Qt.labs.platform

Singleton {
  readonly property string appName: 'ohmyshell'

  readonly property url cache: `${StandardPaths.standardLocations(StandardPaths.GenericCacheLocation)[0]}/${appName}`
  readonly property url config: `${StandardPaths.standardLocations(StandardPaths.GenericConfigLocation)[0]}/${appName}`
}

