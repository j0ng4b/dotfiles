pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components
import qs.services

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: osd
        required property var modelData
        screen: modelData

        readonly property int contentMargins: Config.osd.contentMargins
        readonly property int barWidth: Config.osd.barWidth
        readonly property int iconSize: Config.osd.iconSize
        readonly property int panelWidth: contentMargins * 2 + Math.max(barWidth, iconSize)
        readonly property int panelHeight: Math.round(osd.screen.height * Config.osd.heightFraction)

        readonly property bool isActiveScreen: osd.modelData.name === Niri.focusedOutput

        implicitWidth:  panelWidth
        implicitHeight: panelHeight + cornerTop.size + cornerBottom.size
        anchors.right: true

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        visible: isActiveScreen && (OsdState.visible || container.x < osd.implicitWidth)

        Column {
            id: container

            x: OsdState.visible ? 0 : osd.implicitWidth
            Behavior on x {
                NumberAnimation {
                    duration: 300
                    easing.type: OsdState.visible ? Easing.OutCubic : Easing.InCubic
                }
            }

            Corner {
                id: cornerTop
                anchors.right: parent.right
                side: Corner.Side.BottomRight
                color: Colorscheme.current.surface
            }

            Rectangle {
                id: panel
                width: osd.panelWidth
                height: osd.panelHeight
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
                                color: OsdState.muted
                                    ? Colorscheme.current.error
                                    : Colorscheme.current.primary

                                Behavior on height { NumberAnimation { duration: 200 } }
                                Behavior on color  { ColorAnimation  { duration: 300 } }
                            }
                        }
                    }

                    Icon {
                        icon: OsdState.icon
                        size: osd.iconSize
                        Layout.alignment: Qt.AlignHCenter
                        color: OsdState.muted
                            ? Colorscheme.current.error
                            : Colorscheme.current.primary

                        Behavior on color { ColorAnimation { duration: 300 } }
                    }
                }
            }

            Corner {
                id: cornerBottom
                anchors.right: parent.right
                side: Corner.Side.TopRight
                color: Colorscheme.current.surface
            }
        }
    }
}
