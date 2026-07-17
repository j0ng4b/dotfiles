pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.controlcenter.components.wifi
import qs.modules.controlcenter.components.main
import qs.config
import qs.components
import qs.services

Item {
    id: controlCenter

    required property var screen

    readonly property int panelWidth: 340
    readonly property int edgeMargin: 12

    readonly property bool active: ControlCenterState.isOpen(controlCenter.screen.name)

    // 0 = main controls
    // 1 = wifi network list
    property int page: 0

    onActiveChanged: {
        if (active)
            _resetTimer.stop();
        else
            _resetTimer.restart();
    }

    readonly property var mask: Region {
        width: controlCenter.active ? controlCenter.screen.width : 0
        height: controlCenter.active ? controlCenter.screen.height : 0
    }

    enabled: controlCenter.active

    MouseArea {
        anchors.fill: parent
        enabled: controlCenter.active
        hoverEnabled: true
        onClicked: ControlCenterState.close()
    }

    RowLayout {
        id: container

        readonly property int _hiddenY: -height

        spacing: 0
        width: implicitWidth
        height: implicitHeight

        anchors.right: parent.right
        anchors.rightMargin: controlCenter.edgeMargin

        y: controlCenter.active ? Config.general.barHeight : _hiddenY
        Behavior on y {
            NumberAnimation {
                duration: 300
                easing.type: controlCenter.active ? Easing.OutCubic : Easing.InCubic
            }
        }

        Keys.onEscapePressed: ControlCenterState.close()
        focus: controlCenter.active

        Corner {
            side: Corner.Side.TopRight
            color: Colorscheme.current.surface
            Layout.alignment: Qt.AlignTop
        }

        Rectangle {
            id: panel

            Layout.preferredWidth: controlCenter.panelWidth
            Layout.preferredHeight: {
                switch (controlCenter.page) {
                case 1:
                    return wifiPage.implicitHeight;
                default:
                    return mainPage.implicitHeight;
                }
            }

            Behavior on Layout.preferredHeight {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            color: Colorscheme.current.surface
            bottomLeftRadius: Config.general.radius
            bottomRightRadius: Config.general.radius
            clip: true

            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }

            Item {
                width: controlCenter.panelWidth * 2
                height: parent.height

                x: controlCenter.page === 0 ? 0 : -controlCenter.panelWidth
                Behavior on x {
                    NumberAnimation {
                        duration: 260
                        easing.type: Easing.OutCubic
                    }
                }

                // Main controls
                Item {
                    x: 0
                    width: controlCenter.panelWidth
                    height: parent.height

                    MainPage {
                        id: mainPage
                        anchors.fill: parent

                        onWifiPageRequested: {
                            controlCenter.page = 1;
                            NetworkService.refreshNetworks();
                        }
                    }
                }

                // Wifi network list
                Item {
                    x: controlCenter.panelWidth
                    width: controlCenter.panelWidth
                    height: parent.height

                    WifiPage {
                        id: wifiPage
                        anchors.fill: parent

                        active: controlCenter.active && controlCenter.page === 1
                        onBackRequested: controlCenter.page = 0
                    }
                }
            }
        }

        Corner {
            side: Corner.Side.TopLeft
            color: Colorscheme.current.surface
            Layout.alignment: Qt.AlignTop
        }
    }

    // Resets to the main page after the close animation finishes, so
    // reopening the panel doesn't land on the wifi list unexpectedly.
    Timer {
        id: _resetTimer

        interval: 320
        repeat: false

        onTriggered: controlCenter.page = 0
    }
}
