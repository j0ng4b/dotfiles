pragma Singleton

import Quickshell
import Qt.labs.platform

Singleton {
  readonly property url cache: `${StandardPaths.standardLocations(StandardPaths.GenericCacheLocation)[0]}`
  readonly property url config: `${StandardPaths.standardLocations(StandardPaths.GenericConfigLocation)[0]}`

  function url2Path(url) {
    if (url === undefined || url === null)
      return ''
    return url.toString().replace('file://', '')
  }
}

