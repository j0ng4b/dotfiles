pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.components
import qs.services

Item {
    id: osd

    required property var screen

    readonly property bool active: screen.name === CompositorService.focusedOutput

    readonly property int contentMargins: Config.osd.contentMargins
    readonly property int barWidth: Config.osd.barWidth
    readonly property int iconSize: Config.osd.iconSize
    readonly property int panelWidth: contentMargins * 2 + Math.max(barWidth, iconSize)
    readonly property int panelHeight: Math.round(osd.height * Config.osd.heightFraction)

    readonly property var mask: Region {
        item: container
    }

    enabled: osd.active
    anchors.fill: parent

    Item {
        id: container

        width: osd.panelWidth
        height: cornerTop.size + osd.panelHeight + cornerBottom.size

        anchors.verticalCenter: parent.verticalCenter

        x: (osd.active && OsdState.visible) ? osd.width - width : osd.width
        Behavior on x {
            NumberAnimation {
                duration: 300
                easing.type: OsdState.visible ? Easing.OutCubic : Easing.InCubic
            }
        }

        Corner {
            id: cornerTop
            anchors.right: parent.right
            anchors.bottom: panel.top
            side: Corner.Side.BottomRight
            color: Colorscheme.current.surface
        }

        Rectangle {
            id: panel
            width: osd.panelWidth
            height: osd.panelHeight
            anchors.top: cornerTop.bottom
            anchors.right: parent.right
            topLeftRadius: Config.general.radius
            bottomLeftRadius: Config.general.radius
            color: Colorscheme.current.surface

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: osd.contentMargins
                spacing: 10

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Rectangle {
                        width: osd.barWidth
                        height: parent.height
                        anchors.centerIn: parent
                        radius: 3
                        color: Colorscheme.current.surface_variant

                        Rectangle {
                            width: parent.width
                            height: Math.min(parent.height, parent.height * OsdState.level)
                            anchors.bottom: parent.bottom
                            radius: parent.radius
                            color: OsdState.muted ? Colorscheme.current.error : Colorscheme.current.primary

                            Behavior on height {
                                NumberAnimation {
                                    duration: 200
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 300
                                }
                            }
                        }
                    }
                }

                Icon {
                    icon: OsdState.icon
                    size: osd.iconSize
                    Layout.alignment: Qt.AlignHCenter

                    color: OsdState.muted ? Colorscheme.current.error : Colorscheme.current.primary
                    Behavior on color {
                        ColorAnimation {
                            duration: 300
                        }
                    }
                }
            }
        }

        Corner {
            id: cornerBottom
            anchors.right: parent.right
            anchors.top: panel.bottom
            side: Corner.Side.TopRight
            color: Colorscheme.current.surface
        }
    }
}
