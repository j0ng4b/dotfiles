pragma Singleton

import Quickshell

Singleton {
    id: root
    property bool locked: false
    function lock()   { locked = true;  }
    function unlock() { locked = false; }
}
