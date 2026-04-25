pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.config

Singleton {
    id: root

    // WiFi
    property bool wifiEnabled: false
    property string wifiState: "unknown" // "connected" | "noconnection" | "unknown"
    property int wifiSignalLevel: -100
    property string wifiName: ""

    // Ethernet
    property bool ethernetEnabled: false
    property string ethernetState: "unknown"
    property string ethernetInterface: ""

    property var networks: []

    readonly property string _scripter: Paths.url2Path(Qt.resolvedUrl("../scripts/scripter"))

    // WiFi actions
    function wifiToggle() {
        _action.command = [_scripter, "network", "wifi", "toggle"];
        _action.running = true;
    }

    function wifiConnect(ssid, password) {
        _action.command = [_scripter, "network", "wifi", "connect", ssid];
        if (password)
            _action.command = [..._action.command, password];
        _action.running = true;
    }

    function wifiDisconnect() {
        _action.command = [_scripter, "network", "wifi", "disconnect"];
        _action.running = true;
    }

    function wifiForget(ssid) {
        _action.command = [_scripter, "network", "wifi", "forget", ssid];
        _action.running = true;
    }

    function refreshNetworks() {
        _pollList.running = true;
    }

    // Polling
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            _pollWifi.running = true;
            _pollEthernet.running = true;
        }
    }

    Process {
        id: _pollWifi
        running: false
        command: [root._scripter, "network", "wifi", "status"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const json = JSON.parse(data.trim());
                    root.wifiEnabled = json.enable === 1;
                    root.wifiState = json.state ?? "unknown";
                    root.wifiSignalLevel = json.signal_level ?? -100;
                    root.wifiName = json.name ?? "";
                } catch (e) {
                    console.warn("NetworkService wifi:", e);
                }
            }
        }
    }

    Process {
        id: _pollEthernet
        running: false
        command: [root._scripter, "network", "ethernet", "status"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const j = JSON.parse(data.trim());
                    root.ethernetEnabled = j.enable === 1;
                    root.ethernetState = j.state ?? "unknown";
                    root.ethernetInterface = j.interface ?? "";
                } catch (e) {
                    console.warn("NetworkService ethernet:", e);
                }
            }
        }
    }

    Process {
        id: _pollList
        running: false
        command: [root._scripter, "network", "wifi", "list"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    root.networks = JSON.parse(data.trim());
                } catch (e) {
                    console.warn("NetworkService list:", e);
                }
            }
        }
    }

    // Action process
    Process {
        id: _action
        running: false
        onExited: (exitCode, exitStatus) => {
            _pollWifi.running = true;
            _pollEthernet.running = true;
        }
    }
}
