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

    property string connectingSsid: ""

    readonly property int entryHeight: 42
    readonly property int entrySpacing: 4
    readonly property int maxVisibleEntries: 6

    readonly property real collapsedListHeight: {
        const count = Math.min(NetworkService.networks.length, root.maxVisibleEntries);
        if (count === 0)
            return 0;

        return count * root.entryHeight + (count - 1) * root.entrySpacing;
    }

    readonly property real maxListHeight: root.maxVisibleEntries * root.entryHeight + (root.maxVisibleEntries - 1) * root.entrySpacing

    implicitHeight: content.implicitHeight + 32

    onActiveChanged: {
        if (!active)
            connectingSsid = "";
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

                color: backMa.containsMouse ? Colorscheme.current.surface_container_high : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Icon {
                    anchors.centerIn: parent
                    icon: "chevron_left"
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

                text: "Wi-Fi"
                font.pixelSize: 13
                font.bold: true
                color: Colorscheme.current.on_surface
            }

            Rectangle {
                Layout.preferredWidth: 26
                Layout.preferredHeight: 26

                radius: 13

                color: refreshMa.containsMouse ? Colorscheme.current.surface_container_high : "transparent"
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Icon {
                    id: refreshIcon

                    anchors.centerIn: parent

                    icon: "refresh"
                    size: 15
                    color: Colorscheme.current.on_surface

                    RotationAnimator on rotation {
                        running: NetworkService.scanningNetworks
                        from: 0
                        to: 360
                        duration: 900
                        loops: Animation.Infinite
                    }

                    Connections {
                        target: NetworkService
                        function onScanningNetworksChanged() {
                            if (!NetworkService.scanningNetworks)
                                refreshIcon.rotation = 0;
                        }
                    }
                }

                MouseArea {
                    id: refreshMa

                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: !NetworkService.scanningNetworks
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NetworkService.refreshNetworks()
                }
            }
        }

        ListView {
            id: wifiList

            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(Math.max(wifiList.contentHeight, root.collapsedListHeight), root.maxListHeight)
            Layout.maximumHeight: root.maxListHeight

            visible: NetworkService.networks.length > 0

            clip: true
            spacing: root.entrySpacing
            boundsBehavior: Flickable.StopAtBounds

            model: NetworkService.networks

            delegate: WifiItem {
                required property var modelData

                width: wifiList.width

                network: modelData
                connecting: root.connectingSsid === modelData.ssid

                onConnectRequested: password => {
                    root.connectingSsid = modelData.ssid;
                    NetworkService.wifiConnect(modelData.ssid, password);
                }

                onDisconnectRequested: {
                    root.connectingSsid = modelData.ssid;
                    NetworkService.wifiDisconnect();
                }

                onForgetRequested: NetworkService.wifiForget(modelData.ssid)
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 8

            visible: NetworkService.networks.length === 0

            text: NetworkService.scanningNetworks ? "Scanning..." : "No networks found"
            font.pixelSize: 11
            color: Colorscheme.current.on_surface_variant
        }
    }

    Connections {
        target: NetworkService
        function onNetworksChanged() {
            root.connectingSsid = "";
        }
    }

    Timer {
        interval: 6000
        running: root.active
        repeat: true
        onTriggered: {
            if (!NetworkService.scanningNetworks)
                NetworkService.refreshNetworks();
        }
    }
}
