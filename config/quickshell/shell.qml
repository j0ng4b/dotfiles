import Quickshell
import Quickshell.Io

import qs.config
import qs.modules.bar
import qs.modules.wallpaper
import qs.modules.launcher
import qs.modules.monitors
import qs.modules.lockscreen
import qs.modules.osd
import qs.services

ShellRoot {
    Bar {}
    Launcher {}
    Wallpaper {}
    Monitor {}
    LockScreen {}
    Osd {}

    IpcHandler {
        target: 'wallpaper'

        function set(path: string) {
            Config.wallpaper.source = Qt.resolvedUrl(path);
        }
    }

    IpcHandler {
        target: 'launcher'
        function toggle() {
            LauncherState.toggle(NiriService.focusedOutput);
        }
    }

    IpcHandler {
        target: 'monitors'
        function toggle() {
            MonitorState.toggle();
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
