pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland


ShellRoot {
  LockContext {
    id: lockContext
  }


  WlSessionLock {
    id: lock
    locked: false

    WlSessionLockSurface {
      LockSurface {
        anchors.fill: parent

        lock: lock
        context: lockContext
      }
    }
  }


  IpcHandler {
    target: 'lockscreen'

    function lock() {
      lock.locked = true;
    }

    function unlock() {
      lock.locked = false;
    }
  }
}
