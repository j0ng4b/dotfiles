pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.config

Singleton {
    id: root

    property bool enabled: false
    property bool connected: false
    property string deviceName: ''
    property string deviceMac: ''

    property var devices: []

    readonly property string _scripter: Paths.url2Path(Qt.resolvedUrl('../scripts/scripter'))

    function toggle() {
        _action.command = [root._scripter, 'bluetooth', enabled ? 'off' : 'on'];
        _action.running = true;
    }

    function connectDevice(mac) {
        _action.command = [root._scripter, 'bluetooth', 'connect', mac];
        _action.running = true;
    }

    function disconnectDevice(mac) {
        _action.command = [root._scripter, 'bluetooth', 'disconnect', mac];
        _action.running = true;
    }

    function refreshDevices() {
        _listFetcher.running = true;
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: _statusFetcher.running = true
    }

    Process {
        id: _statusFetcher
        running: false
        command: [root._scripter, 'bluetooth', 'status']
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const json = JSON.parse(this.text.trim());
                    root.enabled = json.enabled ?? false;
                    root.connected = json.connected ?? false;
                    root.deviceName = json.device_name ?? '';
                    root.deviceMac = json.device_mac ?? '';
                } catch (e) {
                    console.warn('Bluetooth: status parse error:', e);
                }
            }
        }
    }

    Process {
        id: _listFetcher
        running: false
        command: [root._scripter, 'bluetooth', 'list', 'paired']
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.devices = JSON.parse(this.text.trim());
                } catch (e) {
                    console.warn('Bluetooth: list parse error:', e);
                }
            }
        }
    }

    Process {
        id: _action
        running: false
        onExited: _statusFetcher.running = true
    }
}
