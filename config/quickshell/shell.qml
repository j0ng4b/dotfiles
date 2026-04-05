import Quickshell
import Quickshell.Io
import qs.modules.bar
import qs.modules.wallpaper
import qs.modules.launcher
import qs.modules.lockscreen
import qs.modules.osd
import qs.services

ShellRoot {
    Bar {}
    Launcher {}
    Wallpaper {}
    LockScreen {}
    Osd {}

    IpcHandler {
        target: 'launcher'
        function toggle() {
            LauncherState.toggle(Niri.focusedOutput);
        }
    }

    IpcHandler {
        target: 'lockscreen'
        function lock()   { LockScreenState.lock();   }
        function unlock() { LockScreenState.unlock(); }
    }
}
