pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

Column {
    id: root

    required property var network

    property bool connecting: false
    property bool _expanded: false

    signal connectRequested(string password)
    signal disconnectRequested
    signal forgetRequested

    readonly property bool isOpen: root.network.security === "open" || root.network.security === ""
    readonly property bool needsPassword: !root.isOpen && !root.network.saved && !root.network.current

    spacing: 4

    onConnectingChanged: {
        if (!root.connecting)
            return;
        root._expanded = false;
        pwInput.clear();
    }

    onNetworkChanged: {
        root._expanded = false;
        pwInput.clear();
    }

    Rectangle {
        id: row

        width: root.width
        height: 42
        radius: Config.general.radius

        color: rowMa.containsMouse ? Colorscheme.current.surface_container_high : "transparent"
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        MouseArea {
            id: rowMa

            anchors.fill: parent

            enabled: !root.connecting
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                if (root.network.current) {
                    root.disconnectRequested();
                    return;
                }

                if (root.needsPassword) {
                    root._expanded = !root._expanded;
                    if (root._expanded)
                        pwInput.forceActiveFocus();

                    return;
                }

                root.connectRequested("");
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 6

            spacing: 8

            Icon {
                icon: {
                    const signalLevel = root.network.signal_level;
                    if (signalLevel >= -60)
                        return "wifi";
                    if (signalLevel >= -70)
                        return "wifi_2_bar";
                    return "wifi_1_bar";
                }

                fill: root.network.current
                size: 16
                color: root.network.current ? Colorscheme.current.primary : Colorscheme.current.on_surface
            }

            Text {
                Layout.fillWidth: true

                text: root.network.ssid
                font.pixelSize: 12
                font.bold: root.network.current
                elide: Text.ElideRight
                color: Colorscheme.current.on_surface
            }

            Icon {
                visible: !root.isOpen

                icon: "lock"
                size: 13
                color: Colorscheme.current.on_surface_variant
            }

            Icon {
                visible: root.connecting

                icon: "progress_activity"
                size: 15
                color: Colorscheme.current.primary

                RotationAnimator on rotation {
                    running: root.connecting
                    from: 0
                    to: 360
                    duration: 900
                    loops: Animation.Infinite
                }
            }

            Rectangle {
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22

                visible: root.network.saved && !root.connecting
                radius: 11

                color: forgetMa.containsMouse ? Colorscheme.current.error_container : "transparent"
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Icon {
                    anchors.centerIn: parent

                    icon: "close"
                    size: 13
                    color: forgetMa.containsMouse ? Colorscheme.current.on_error_container : Colorscheme.current.on_surface_variant
                }

                MouseArea {
                    id: forgetMa

                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root._expanded = false;
                        pwInput.clear();
                        root.forgetRequested();
                    }
                }
            }
        }
    }

    Rectangle {
        id: passwordContainer

        width: root.width
        height: 38

        visible: root._expanded

        radius: Config.general.radius
        color: Colorscheme.current.surface_container

        RowLayout {
            anchors.fill: parent
            anchors.margins: 6

            spacing: 6

            TextInput {
                id: pwInput

                Layout.fillWidth: true
                Layout.leftMargin: 6

                enabled: !root.connecting

                font.pixelSize: 12
                color: Colorscheme.current.on_surface
                selectionColor: Colorscheme.current.primary
                selectedTextColor: Colorscheme.current.on_primary

                echoMode: TextInput.Password
                clip: true

                Keys.onEscapePressed: {
                    root._expanded = false;
                    pwInput.clear();
                    row.forceActiveFocus();
                }

                Keys.onReturnPressed: connectBtn.trigger()
                Keys.onEnterPressed: connectBtn.trigger()
            }

            Rectangle {
                id: connectBtn

                Layout.preferredWidth: 60
                Layout.preferredHeight: 26

                readonly property bool available: pwInput.text.length > 0 && !root.connecting

                radius: 6
                color: connectBtn.available ? Colorscheme.current.primary : Colorscheme.current.surface_container_high

                function trigger() {
                    if (!connectBtn.available)
                        return;

                    const password = pwInput.text;

                    pwInput.clear();
                    root._expanded = false;
                    root.connectRequested(password);
                }

                Text {
                    anchors.centerIn: parent

                    text: "Connect"
                    font.pixelSize: 11
                    color: connectBtn.available ? Colorscheme.current.on_primary : Colorscheme.current.on_surface_variant
                }

                MouseArea {
                    anchors.fill: parent

                    enabled: connectBtn.available
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: connectBtn.trigger()
                }
            }
        }
    }
}
