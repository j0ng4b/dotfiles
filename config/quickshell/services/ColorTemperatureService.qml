pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    readonly property string scriptPath: Paths.url2Path(Qt.resolvedUrl("../scripts/scripter"))

    property string mode: "auto"  // "auto" | "high" | "low"
    property bool enabled: false

    readonly property bool isAuto: root.mode === "auto"
    readonly property bool isDay: root.mode === "high"
    readonly property bool isNight: root.mode === "low"

    function setMode(mode) {
        _action.command = [root.scriptPath, "color-temperature", "set", mode];
        _action.running = true;
    }

    function toggle() {
        root.setMode(root.isNight ? "high" : "low");
    }

    function setAuto() {
        root.setMode("auto");
    }

    function cycle() {
        _action.command = [root.scriptPath, "color-temperature", "cycle"];
        _action.running = true;
    }

    function updateStatus(text) {
        try {
            const json = JSON.parse(text.trim());

            root.enabled = json.enabled ?? false;
            root.mode = json.mode ?? "auto";
        } catch (error) {
            console.warn("ColorTemperature: failed to parse status:", error, text);
        }
    }

    Process {
        id: _watcher

        running: true
        command: [root.scriptPath, "color-temperature", "watch"]

        stdout: SplitParser {
            onRead: data => root.updateStatus(data)
        }

        onExited: (exitCode, exitStatus) => {
            console.warn("ColorTemperature: watcher exited:", exitCode, exitStatus);
            _restartTimer.restart();
        }
    }

    Process {
        id: _action
        running: false

        onExited: {
            if (!_watcher.running)
                _restartTimer.restart();
        }
    }

    Timer {
        id: _restartTimer

        interval: 1000
        repeat: false

        onTriggered: {
            if (!_watcher.running)
                _watcher.running = true;
        }
    }

    Component.onDestruction: {
        _watcher.running = false;
        _action.running = false;
    }
}
