import Quickshell
import Quickshell.Io
import qs.modules.bar
import qs.modules.wallpaper
import qs.modules.launcher
import qs.modules.lockscreen

ShellRoot {
    Bar {}
    Launcher {}
    Wallpaper {}
    LockScreen {}

    IpcHandler {
        target: 'launcher'
        function toggle() {
            LauncherState.toggle();
        }
    }
}
