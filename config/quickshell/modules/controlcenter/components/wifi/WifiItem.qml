pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

Item {
    id: root

    required property var network
    property bool connecting: false

    signal connectRequested(string password)
    signal disconnectRequested
    signal forgetRequested
    signal passwordRequired

    readonly property bool isOpen: root.network.security === "open" || root.network.security === ""
    readonly property bool needsPassword: !root.isOpen && !root.network.saved && !root.network.current
    readonly property int headerHeight: 42

    implicitHeight: root.headerHeight

    Rectangle {
        id: container

        width: root.width
        height: root.headerHeight
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
                    root.passwordRequired();
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
                    const s = root.network.signal_level;
                    if (s >= -60)
                        return "wifi";
                    if (s >= -70)
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
                    onClicked: root.forgetRequested()
                }
            }
        }
    }
}
