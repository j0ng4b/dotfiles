import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components
import qs.services
import qs.modules.bar.workspaces
import qs.modules.launcher

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: bar
        required property var modelData
        screen: modelData

        anchors.top: true
        anchors.left: true
        anchors.right: true

        color: 'transparent'
        exclusiveZone: contentHeight - 10

        implicitHeight: container.height
        property int contentHeight: 30

        mask: Region {
            Region { item: content }
            Region { item: leftCorner }
            Region { item: rightCorner }
        }

        Column {
            id: container

            Rectangle {
                color: Colorscheme.current.surface

                implicitWidth: content.width
                implicitHeight: content.height

                Item {
                    id: content
                    implicitWidth: bar.width
                    implicitHeight: bar.contentHeight

                    Rectangle {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 7

                        width: 26
                        height: 26
                        radius: 6
                        color: launcherBtn.containsMouse
                            ? Colorscheme.current.surface_container_high
                            : 'transparent'

                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            font.family: 'Material Symbols Rounded Filled'
                            font.pixelSize: 20
                            color: launcherBtn.containsMouse
                                ? Colorscheme.current.primary
                                : Colorscheme.current.on_surface

                            Behavior on color { ColorAnimation { duration: 150 } }

                            text: 'grid_view'
                        }

                        MouseArea {
                            id: launcherBtn
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: LauncherState.toggle(bar.modelData.name)
                        }
                    }

                    Workspaces {
                        output: bar.screen
                        anchors.centerIn: parent
                    }

                    ColumnLayout {
                        anchors.right: parent.right
                        anchors.margins: 5
                        spacing: 2

                        Text {
                            Layout.alignment: Qt.AlignCenter
                            text: Clock.time
                            font.pixelSize: 12
                            color: Colorscheme.current.on_surface
                        }

                        Text {
                            Layout.alignment: Qt.AlignCenter
                            text: Clock.date
                            font.pixelSize: 10
                            color: Colorscheme.current.on_surface
                        }
                    }
                }
            }

            RowLayout {
                width: content.width

                Corner {
                    id: leftCorner
                    side: Corner.Side.TopLeft
                    color: Colorscheme.current.surface
                    Layout.alignment: Qt.AlignLeft
                }

                Corner {
                    id: rightCorner
                    side: Corner.Side.TopRight
                    color: Colorscheme.current.surface
                    Layout.alignment: Qt.AlignRight
                }
            }
        }
    }
}
