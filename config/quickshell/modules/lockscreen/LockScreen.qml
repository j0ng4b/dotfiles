pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    LockContext { id: lockContext }

    WlSessionLock {
        id: lock
        locked: LockScreenState.locked

        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                lock: lock
                context: lockContext
            }
        }
    }
}
