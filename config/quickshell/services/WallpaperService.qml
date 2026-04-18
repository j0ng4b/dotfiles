pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import QtCore
import qs.config

Singleton {
    id: root

    property list<string> wallpapers: []
    property bool scanning: scanner.running

    readonly property string wallpaperDir: {
        let path = Config.launcher.wallpaperDir;

        if (path.startsWith("~/"))
            path = '"$HOME/' + path.slice(2) + '"';

        return path;
    }

    function rescan() {
        if (scanner.running)
            return;

        wallpapers = [];
        scanner.running = true;
    }

    Process {
        id: scanner
        running: false

        command: [
            "sh", "-c",
            "find " + root.wallpaperDir + " -maxdepth 2 -type f " +
            "\\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' " +
            "-o -iname '*.webp' -o -iname '*.bmp' -o -iname '*.gif' \\) " +
            '2>/dev/null'
        ]

        stdout: SplitParser {
            onRead: data => {
                const path = data.trim();
                if (path !== "")
                    root.wallpapers = [...root.wallpapers, path];
            }
        }
    }
}
