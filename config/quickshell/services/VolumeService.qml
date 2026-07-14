pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    property real level: 0.0
    property bool muted: false
    property string type: "speaker"

    signal changed

    function setVolume(value) {
        _setProcess.command = [Paths.url2Path(Qt.resolvedUrl("../scripts/scripter")), "multimedia", "speaker", "set", String(Math.round(value * 100))];
        _setProcess.running = true;
    }

    Process {
        id: _setProcess
        running: false
    }

    Process {
        running: true
        command: [Paths.url2Path(Qt.resolvedUrl("../scripts/scripter")), "multimedia", "watch"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const json = JSON.parse(data.trim());
                    const speaker = json.speaker;
                    if (!speaker)
                        return;

                    root.level = Math.min(parseFloat(speaker.volume), 1.0);
                    root.muted = speaker.mute === 1;

                    switch (speaker.type) {
                    case "headphones":
                        root.type = "headphones";
                        break;
                    default:
                        root.type = "speaker";
                        break;
                    }

                    if (speaker.changed)
                        root.changed();
                } catch (e) {
                    console.warn("Volume: parse error:", e);
                }
            }
        }
    }
}
