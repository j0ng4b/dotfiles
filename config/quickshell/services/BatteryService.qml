pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.config

Singleton {
    id: root

    enum State {
        Charging,
        Discharging
    }

    property int capacity: 0
    property var state: BatteryService.State.Discharging

    signal changed

    Process {
        running: true
        command: [Paths.url2Path(Qt.resolvedUrl("../scripts/scripter")), "battery", "watch"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const json = JSON.parse(data.trim());
                    root.capacity = json.capacity;

                    switch (json.state) {
                    case "charging":
                        root.state = BatteryService.State.Charging;
                        break;
                    case "discharging":
                        root.state = BatteryService.State.Discharging;
                        break;
                    }
                } catch (e) {
                    console.warn("Battery: parse error:", e);
                }
            }
        }
    }
}
