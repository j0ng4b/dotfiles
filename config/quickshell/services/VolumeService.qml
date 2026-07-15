pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    signal changed

    readonly property string scriptPath: Paths.url2Path(Qt.resolvedUrl("../scripts/scripter"))

    property real level: 0.0
    property bool muted: false
    property string type: "speaker"

    function setVolume(value) {
        _action.command = [root.scriptPath, "multimedia", "speaker", "set", String(Math.round(value * 100))];
        _action.running = true;
    }

    function toggleMute() {
        _action.command = [root.scriptPath, "multimedia", "speaker", "mute"];
        _action.running = true;
    }

    Process {
        id: _action
        running: false
    }

    Process {
        id: _watcher

        running: true
        command: [root.scriptPath, "multimedia", "watch"]

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
                    console.warn("VolumeService: parse error:", e);
                }
            }
        }
    }

    Component.onDestruction: {
        _watcher.running = false;
        _action.running = false;
    }
}
