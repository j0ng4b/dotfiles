pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

Item {
    id: root

    required property var device
    property bool busy: false

    signal connectRequested
    signal disconnectRequested
    signal pairRequested
    signal forgetRequested

    readonly property int rowHeight: 42

    implicitHeight: rowHeight

    Rectangle {
        id: container
        width: root.width
        height: root.rowHeight
        radius: Config.general.radius

        color: rowMa.containsMouse ? Colorscheme.current.surface_container_high : 'transparent'
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        MouseArea {
            id: rowMa
            anchors.fill: parent
            enabled: !root.busy
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                if (root.device.connected) {
                    root.disconnectRequested();
                    return;
                }

                if (root.device.paired) {
                    root.connectRequested();
                    return;
                }

                root.pairRequested();
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 6
            spacing: 8

            Icon {
                icon: root.device.connected ? 'bluetooth_connected' : 'bluetooth'
                fill: root.device.connected
                size: 16
                color: root.device.connected ? Colorscheme.current.primary : Colorscheme.current.on_surface
            }

            Text {
                Layout.fillWidth: true
                text: root.device.alias || root.device.name
                font.pixelSize: 12
                font.bold: root.device.connected
                elide: Text.ElideRight
                color: Colorscheme.current.on_surface
            }

            Text {
                visible: root.device.battery !== null && root.device.battery !== undefined
                text: (root.device.battery ?? 0) + '%'
                font.pixelSize: 10
                color: Colorscheme.current.on_surface_variant
            }

            Icon {
                visible: root.busy
                icon: 'progress_activity'
                size: 15
                color: Colorscheme.current.primary

                RotationAnimator on rotation {
                    running: root.busy
                    from: 0
                    to: 360
                    duration: 900
                    loops: Animation.Infinite
                }
            }

            Rectangle {
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22

                visible: root.device.paired && !root.busy
                radius: 11

                color: forgetMa.containsMouse ? Colorscheme.current.error_container : 'transparent'
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Icon {
                    anchors.centerIn: parent
                    icon: 'close'
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
