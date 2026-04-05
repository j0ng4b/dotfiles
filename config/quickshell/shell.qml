import Quickshell
import Quickshell.Io
import qs.modules.bar
import qs.modules.wallpaper
import qs.modules.launcher
import qs.modules.lockscreen
import qs.modules.osd

ShellRoot {
    Bar {}
    Launcher {}
    Wallpaper {}
    LockScreen {}
    Osd {}

    IpcHandler {
        target: 'launcher'
        function toggle() {
            LauncherState.toggle();
        }
    }
}
