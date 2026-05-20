import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components
import qs.services
import qs.modules.launcher

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: bar
        required property var modelData
        screen: modelData

        property int contentHeight: 30

        anchors.top: true

        color: 'transparent'
        exclusiveZone: contentHeight

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: Config.shellName + '-bar'
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        implicitWidth: screen.width
        implicitHeight: screen.height

        mask: Region {
            item: content
        }

        ColumnLayout {
            id: container
            spacing: 0
            anchors.fill: parent

            Rectangle {
                color: Colorscheme.current.surface

                Layout.preferredWidth: content.width
                Layout.preferredHeight: content.height

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

                        color: launcherBtn.containsMouse ? Colorscheme.current.surface_container_high : 'transparent'
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Icon {
                            icon: 'grid_view'
                            fill: launcherBtn.containsMouse
                            anchors.centerIn: parent
                            color: launcherBtn.containsMouse ? Colorscheme.current.primary : Colorscheme.current.on_surface

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }
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

                    RowLayout {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: 8
                        spacing: 6

                        SystemTray {
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Rectangle {
                            color: Colorscheme.current.on_surface
                            opacity: 0.2
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 14
                            Layout.alignment: Qt.AlignVCenter
                        }

                        ColumnLayout {
                            spacing: 2
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredHeight: parent.height

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: ClockService.time
                                font.pixelSize: 11
                                color: Colorscheme.current.on_surface
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: ClockService.date
                                font.pixelSize: 9
                                color: Colorscheme.current.on_surface
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.preferredWidth: content.width

                Corner {
                    side: Corner.Side.TopLeft
                    color: Colorscheme.current.surface
                    Layout.alignment: Qt.AlignLeft
                }

                Corner {
                    side: Corner.Side.TopRight
                    color: Colorscheme.current.surface
                    Layout.alignment: Qt.AlignRight
                }
            }

            Item {
                Layout.fillHeight: true
            }

            RowLayout {
                Layout.preferredWidth: content.width

                Corner {
                    side: Corner.Side.BottomLeft
                    color: Colorscheme.current.surface
                    Layout.alignment: Qt.AlignLeft
                }

                Corner {
                    side: Corner.Side.BottomRight
                    color: Colorscheme.current.surface
                    Layout.alignment: Qt.AlignRight
                }
            }
        }
    }
}
