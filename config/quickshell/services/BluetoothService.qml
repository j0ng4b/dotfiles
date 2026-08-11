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
    readonly property bool scanning: _scanner.running

    readonly property string _scripter: Paths.url2Path(Qt.resolvedUrl('../scripts/scripter'))
    property string _pendingConnectMac: ''

    function toggle() {
        root._pendingConnectMac = '';

        _action.command = [root._scripter, 'bluetooth', enabled ? 'off' : 'on'];
        _action.running = true;
    }

    function connectDevice(mac) {
        root._pendingConnectMac = '';

        _action.command = [root._scripter, 'bluetooth', 'connect', mac];
        _action.running = true;
    }

    function disconnectDevice(mac) {
        root._pendingConnectMac = '';

        _action.command = [root._scripter, 'bluetooth', 'disconnect', mac];
        _action.running = true;
    }

    // Pair and, on success, immediately try to connect.
    function pairDevice(mac) {
        root._pendingConnectMac = mac;

        _action.command = [root._scripter, 'bluetooth', 'pair', mac];
        _action.running = true;
    }

    function forgetDevice(mac) {
        root._pendingConnectMac = '';

        _action.command = [root._scripter, 'bluetooth', 'forget', mac];
        _action.running = true;
    }

    function refreshDevices() {
        _listFetcher.command = [root._scripter, 'bluetooth', 'list', 'paired'];
        _listFetcher.running = true;
    }

    function scan(duration) {
        if (_scanner.running)
            return;

        _scanner.command = [root._scripter, 'bluetooth', 'scan', String(duration ?? 8)];
        _scanner.running = true;
    }

    function _mergeDevices(incoming) {
        const merged = {};

        for (const device of root.devices)
            merged[device.mac] = device;

        for (const device of incoming)
            merged[device.mac] = device;

        root.devices = Object.values(merged).sort((a, b) => {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;
            if (a.paired !== b.paired)
                return a.paired ? -1 : 1;
            return (a.alias || a.name).localeCompare(b.alias || b.name);
        });
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

                    if (root.enabled)
                        root.refreshDevices();
                    else
                        root.devices = [];
                } catch (e) {
                    console.warn('Bluetooth: status parse error:', e);
                }
            }
        }
    }

    Process {
        id: _listFetcher
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root._mergeDevices(JSON.parse(this.text.trim()));
                } catch (e) {
                    console.warn('Bluetooth: list parse error:', e);
                }
            }
        }
    }

    Process {
        id: _scanner
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root._mergeDevices(JSON.parse(this.text.trim()));
                } catch (e) {
                    console.warn('Bluetooth: scan parse error:', e);
                }
            }
        }
    }

    Process {
        id: _action
        running: false
        onExited: {
            if (root._pendingConnectMac !== '') {
                const mac = root._pendingConnectMac;
                root._pendingConnectMac = '';
                root.connectDevice(mac);
                return;
            }

            _statusFetcher.running = true;
            root.refreshDevices();
        }
    }
}
