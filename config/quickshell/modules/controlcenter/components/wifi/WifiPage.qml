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
    property var _popupNetwork: null   // rede selecionada para senha

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
        if (!active) {
            connectingSsid = "";
            _popupNetwork = null;
            _pwInput.clear();
        }
    }

    function _doConnect() {
        if (_pwInput.text.length === 0)
            return;
        const password = _pwInput.text;
        const network = root._popupNetwork;
        _pwInput.clear();
        root._popupNetwork = null;
        root.connectingSsid = network.ssid;
        NetworkService.wifiConnect(network.ssid, password);
    }

    ColumnLayout {
        id: content

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 16
        spacing: 10

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

                onPasswordRequired: root._popupNetwork = modelData

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

    Item {
        id: _overlay

        anchors.fill: parent
        visible: root._popupNetwork !== null
        z: 10

        onVisibleChanged: {
            if (visible)
                _pwInput.forceActiveFocus();
        }

        Rectangle {
            anchors.fill: parent
            radius: Config.general.radius
            color: Qt.rgba(0, 0, 0, 0.45)

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root._popupNetwork = null;
                    _pwInput.clear();
                }
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width - 32
            height: _card.implicitHeight + 32
            radius: Config.general.radius
            color: Colorscheme.current.surface_container_high

            ColumnLayout {
                id: _card

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 16
                }
                spacing: 12

                Text {
                    Layout.fillWidth: true
                    text: root._popupNetwork?.ssid ?? ""
                    font.pixelSize: 13
                    font.bold: true
                    color: Colorscheme.current.on_surface
                    elide: Text.ElideRight
                }

                // Input de senha
                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    radius: 6
                    color: Colorscheme.current.surface_container

                    // Placeholder manual
                    Text {
                        anchors {
                            fill: parent
                            leftMargin: 10
                        }
                        verticalAlignment: Text.AlignVCenter
                        text: "Password"
                        font.pixelSize: 12
                        color: Colorscheme.current.on_surface_variant
                        visible: _pwInput.text.length === 0
                    }

                    TextInput {
                        id: _pwInput

                        anchors {
                            fill: parent
                            leftMargin: 10
                            rightMargin: 10
                        }
                        verticalAlignment: TextInput.AlignVCenter
                        font.pixelSize: 12
                        color: Colorscheme.current.on_surface
                        selectionColor: Colorscheme.current.primary
                        selectedTextColor: Colorscheme.current.on_primary
                        echoMode: TextInput.Password
                        clip: true

                        Keys.onReturnPressed: root._doConnect()
                        Keys.onEnterPressed: root._doConnect()
                        Keys.onEscapePressed: {
                            root._popupNetwork = null;
                            _pwInput.clear();
                        }
                    }
                }

                // Botões
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true
                        height: 30
                        radius: 6
                        color: _cancelMa.containsMouse ? Colorscheme.current.surface_container : Colorscheme.current.surface_container_low
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "Cancel"
                            font.pixelSize: 11
                            color: Colorscheme.current.on_surface
                        }

                        MouseArea {
                            id: _cancelMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root._popupNetwork = null;
                                _pwInput.clear();
                            }
                        }
                    }

                    Rectangle {
                        id: _connectBtn

                        Layout.fillWidth: true
                        height: 30
                        radius: 6

                        readonly property bool available: _pwInput.text.length > 0
                        color: available ? Colorscheme.current.primary : Colorscheme.current.surface_container
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "Connect"
                            font.pixelSize: 11
                            color: _connectBtn.available ? Colorscheme.current.on_primary : Colorscheme.current.on_surface_variant
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: _connectBtn.available
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: root._doConnect()
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: NetworkService
        function onNetworksChanged() {
            root.connectingSsid = "";
            if (root._popupNetwork !== null) {
                const found = NetworkService.networks.some(n => n.ssid === root._popupNetwork.ssid);
                if (!found) {
                    root._popupNetwork = null;
                    _pwInput.clear();
                }
            }
        }
    }

    Timer {
        interval: 6000
        running: root.active
        repeat: true
        onTriggered: {
            if (!NetworkService.scanningNetworks && root._popupNetwork === null && root.connectingSsid === "")
                NetworkService.refreshNetworks();
        }
    }
}
