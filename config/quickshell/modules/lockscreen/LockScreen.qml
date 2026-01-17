pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland


ShellRoot {
  LockContext {
    id: lockContext
    onUnlocked: lock.locked = false;
  }


  WlSessionLock {
    id: lock

    locked: false

    WlSessionLockSurface {
      LockSurface {
        anchors.fill: parent
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
