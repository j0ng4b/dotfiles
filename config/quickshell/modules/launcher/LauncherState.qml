pragma Singleton

import Quickshell
import Quickshell.Io
import qs.services

Singleton {
    id: root

    property bool open: false
    property string activeScreen: ''
    property string activeTab: 'apps'

    function isOpen(screenName) {
        if (open && (activeScreen == screenName || activeScreen == ''))
            return true;
        return false;
    }

    function toggle(screenName) {
        if (screenName === undefined || screenName === null) {
            open = !open;
            if (!open)
                activeScreen = '';
            return;
        }

        if (open && activeScreen === screenName) {
            open = false;
            activeScreen = '';
        } else {
            activeScreen = screenName;
            open = true;
        }
    }

    function close() {
        open = false;
        activeScreen = '';
    }

    function switchTab(tab) {
        activeTab = tab;
    }

    IpcHandler {
        target: "launcher"

        function toggle() {
            root.toggle(CompositorService.focusedOutput);
        }
    }
}
