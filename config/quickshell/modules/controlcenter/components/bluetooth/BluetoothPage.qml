pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components
import qs.services

Item {
    id: root

    required property bool active

    signal backRequested

    property string busyMac: ''

    readonly property int entryHeight: 42
    readonly property int entrySpacing: 4
    readonly property int maxVisibleEntries: 6

    readonly property real collapsedListHeight: {
        const count = Math.min(BluetoothService.devices.length, root.maxVisibleEntries);
        if (count === 0)
            return 0;
        return count * root.entryHeight + (count - 1) * root.entrySpacing;
    }

    readonly property real maxListHeight: root.maxVisibleEntries * root.entryHeight + (root.maxVisibleEntries - 1) * root.entrySpacing

    implicitHeight: content.implicitHeight + 32

    onActiveChanged: {
        if (!active)
            busyMac = '';
    }

    ColumnLayout {
        id: content
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 16
        spacing: 10

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: 14
                color: backMa.containsMouse ? Colorscheme.current.surface_container_high : 'transparent'
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Icon {
                    anchors.centerIn: parent
                    icon: 'chevron_left'
                    size: 18
                    color: Colorscheme.current.on_surface
                }

                MouseArea {
                    id: backMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.backRequested()
                }
            }

            Text {
                Layout.fillWidth: true
                text: 'Bluetooth'
                font.pixelSize: 13
                font.bold: true
                color: Colorscheme.current.on_surface
            }

            Rectangle {
                Layout.preferredWidth: 26
                Layout.preferredHeight: 26
                radius: 13
                color: scanMa.containsMouse ? Colorscheme.current.surface_container_high : 'transparent'
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Icon {
                    id: scanIcon
                    anchors.centerIn: parent
                    icon: 'refresh'
                    size: 15
                    color: Colorscheme.current.on_surface

                    RotationAnimator on rotation {
                        running: BluetoothService.scanning
                        from: 0
                        to: 360
                        duration: 900
                        loops: Animation.Infinite
                    }

                    Connections {
                        target: BluetoothService
                        function onScanningChanged() {
                            if (!BluetoothService.scanning)
                                scanIcon.rotation = 0;
                        }
                    }
                }

                MouseArea {
                    id: scanMa
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: !BluetoothService.scanning
                    cursorShape: Qt.PointingHandCursor
                    onClicked: BluetoothService.scan()
                }
            }
        }

        ListView {
            id: deviceList
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(Math.max(deviceList.contentHeight, root.collapsedListHeight), root.maxListHeight)
            Layout.maximumHeight: root.maxListHeight

            visible: BluetoothService.devices.length > 0
            clip: true
            spacing: root.entrySpacing
            boundsBehavior: Flickable.StopAtBounds

            model: BluetoothService.devices

            delegate: BluetoothItem {
                required property var modelData

                width: deviceList.width

                device: modelData
                busy: root.busyMac === modelData.mac

                onConnectRequested: {
                    root.busyMac = modelData.mac;
                    BluetoothService.connectDevice(modelData.mac);
                }

                onDisconnectRequested: {
                    root.busyMac = modelData.mac;
                    BluetoothService.disconnectDevice(modelData.mac);
                }

                onPairRequested: {
                    root.busyMac = modelData.mac;
                    BluetoothService.pairDevice(modelData.mac);
                }

                onForgetRequested: BluetoothService.forgetDevice(modelData.mac)
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 8

            visible: BluetoothService.devices.length === 0

            text: BluetoothService.scanning ? 'Scanning...' : 'No devices found'
            font.pixelSize: 11
            color: Colorscheme.current.on_surface_variant
        }
    }

    Connections {
        target: BluetoothService
        function onDevicesChanged() {
            root.busyMac = '';
        }
    }
}
