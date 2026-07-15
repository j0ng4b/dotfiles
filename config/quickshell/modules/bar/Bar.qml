pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.components
import qs.services
import qs.modules.launcher
import qs.modules.controlcenter

Item {
    id: bar

    required property var screen
    property int contentHeight: Config.general.barHeight

    readonly property var mask: Region {
        item: content
    }

    anchors.fill: parent

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
                        onClicked: LauncherState.toggle(bar.screen.name)
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

                    StatusTray {
                        Layout.alignment: Qt.AlignVCenter
                        onIndicatorClicked: ControlCenterState.toggle(bar.screen.name)
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
