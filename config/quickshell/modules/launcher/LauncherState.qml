pragma Singleton

import Quickshell

Singleton {
    id: root

    property bool open: false
    property string activeScreen: ""

    function isOpen(screenName) {
        if (open && (activeScreen == screenName || activeScreen == ""))
            return true;
        return false;
    }

    function toggle(screenName) {
        if (screenName === undefined || screenName === null) {
            open = !open;
            if (!open)
                activeScreen = "";

            return;
        }

        if (open && activeScreen === screenName) {
            open = false;
            activeScreen = "";
        } else {
            activeScreen = screenName;
            open = true;
        }
    }

    function close() {
        open = false;
        activeScreen = "";
    }
}
