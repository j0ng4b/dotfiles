pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.config

Singleton {
    id: root

    property real screen: -1.0
    property real kbd: -1.0

    signal changed(source: string)

    Process {
        running: true
        command: [
            Paths.url2Path(Qt.resolvedUrl("../scripts/scripter")),
            "brightness", "watch"
        ]

        stdout: SplitParser {
            onRead: data => {
                try {
                    const json = JSON.parse(data.trim());

                    if (json.screen) {
                        root.screen = parseInt(json.screen.current) / parseInt(json.screen.max);

                        if (json.screen.changed)
                            root.changed("screen");
                    }

                    if (json.keyboard) {
                        root.kbd = parseInt(json.keyboard.current) / parseInt(json.keyboard.max);

                        if (json.keyboard.changed)
                            root.changed("keyboard");
                    }
                } catch (e) {
                    console.warn("Brightness: parse error:", e);
                }
            }
        }

        onExited: (code, status) => {
            if (code !== 0) {
                root.screen = -1.0;
                root.kbd = -1.0;
            }
        }
    }
}
