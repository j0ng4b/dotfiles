// NOTE:
// To enable proper code completion and diagnostics with qmlls (QML Language Server),
// create a `.qmlls.ini` file in the root directory of your Quickshell configuration.
// Quickshell will automatically detect this file and populate it with the required
// LSP configuration. Since the generated configuration is system-dependent, it
// should be added to `.gitignore`.
import QtQml
import Quickshell
import Quickshell.Io

import qs.config
import qs.modules
import qs.modules.wallpaper
import qs.modules.monitors
import qs.modules.lockscreen

ShellRoot {
    Wallpaper {}
    LockScreen {}
    Monitor {}
    UiShell {}

    IpcHandler {
        target: 'wallpaper'

        function set(path: string) {
            Config.wallpaper.source = Qt.resolvedUrl(path);
        }
    }

    IpcHandler {
        target: 'lockscreen'

        function lock() {
            LockScreenState.lock();
        }

        function unlock() {
            LockScreenState.unlock();
        }
    }
}
