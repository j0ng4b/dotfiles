pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.notifications
import qs.config
import qs.components
import qs.services

Item {
    id: controlCenter

    required property var screen
    readonly property int panelWidth: 340
    readonly property int edgeMargin: 12

    property bool historyExpanded: false
    property real _historyNow: Date.now()

    readonly property bool active: ControlCenterState.isOpen(controlCenter.screen.name)

    readonly property var mask: Region {
        width: controlCenter.active ? controlCenter.screen.width : 0
        height: controlCenter.active ? controlCenter.screen.height : 0
    }

    enabled: controlCenter.active

    MouseArea {
        anchors.fill: parent
        enabled: controlCenter.active
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
            Layout.preferredHeight: panelColumn.implicitHeight + 32

            color: Colorscheme.current.surface
            bottomLeftRadius: Config.general.radius
            bottomRightRadius: Config.general.radius

            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }

            ColumnLayout {
                id: panelColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 16
                spacing: 14

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    QuickToggle {
                        Layout.fillWidth: true
                        icon: NetworkService.wifiEnabled ? 'wifi' : 'wifi_off'
                        label: NetworkService.wifiEnabled ? (NetworkService.wifiName !== '' ? NetworkService.wifiName : 'On') : 'Off'
                        active: NetworkService.wifiEnabled
                        onClicked: NetworkService.wifiToggle()
                    }

                    QuickToggle {
                        Layout.fillWidth: true
                        icon: BluetoothService.enabled ? 'bluetooth' : 'bluetooth_disabled'
                        label: BluetoothService.enabled ? (BluetoothService.connected ? BluetoothService.deviceName : 'On') : 'Off'
                        active: BluetoothService.enabled
                        onClicked: BluetoothService.toggle()
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    QuickToggle {
                        Layout.fillWidth: true
                        icon: ColorTemperatureService.isNight ? 'dark_mode' : 'light_mode'
                        label: ColorTemperatureService.isNight ? 'Night' : 'Day'
                        active: ColorTemperatureService.isNight
                        onClicked: ColorTemperatureService.toggle()
                    }

                    QuickToggle {
                        Layout.fillWidth: true
                        icon: NotificationsState.dnd ? 'notifications_off' : 'notifications'
                        label: NotificationsState.dnd ? 'DND On' : 'DND Off'
                        active: NotificationsState.dnd
                        onClicked: NotificationsState.toggleDnd()
                    }
                }

                Slider {
                    Layout.fillWidth: true
                    icon: {
                        if (VolumeService.muted)
                            return 'volume_off';
                        if (VolumeService.level > 0.6)
                            return 'volume_up';
                        if (VolumeService.level > 0.15)
                            return 'volume_down';
                        return 'volume_mute';
                    }
                    value: VolumeService.level
                    onMoved: value => {
                        _volumeDebounce.pendingValue = value;
                        _volumeDebounce.restart();
                    }
                    onIconClicked: VolumeService.toggleMute()
                }

                Slider {
                    Layout.fillWidth: true
                    icon: {
                        if (BrightnessService.screen < 0.34)
                            return 'brightness_low';
                        if (BrightnessService.screen < 0.67)
                            return 'brightness_medium';

                        return 'brightness_high';
                    }
                    value: Math.max(0, BrightnessService.screen)
                    onMoved: value => {
                        _brightnessDebounce.pendingValue = value;
                        _brightnessDebounce.restart();
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: weatherRow.implicitHeight + 20
                    radius: Config.general.radius
                    color: Colorscheme.current.surface_container

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: WeatherService.refresh()
                    }

                    RowLayout {
                        id: weatherRow
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: 12
                        spacing: 10

                        Icon {
                            id: weatherIcon
                            icon: WeatherService.loading ? 'refresh' : WeatherService.icon
                            fill: true
                            size: 22
                            color: Colorscheme.current.primary

                            Connections {
                                target: WeatherService

                                function onLoadingChanged() {
                                    if (!WeatherService.loading)
                                        weatherIcon.rotation = 0;
                                }
                            }

                            RotationAnimator on rotation {
                                running: WeatherService.loading
                                from: 0
                                to: 360
                                duration: 1200
                                loops: Animation.Infinite
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: {
                                    if (!WeatherService.hasData)
                                        return 'Weather unavailable';
                                    return Math.round(WeatherService.tempC) + '°C · ' + WeatherService.description;
                                }
                                font.pixelSize: 12
                                font.bold: true
                                elide: Text.ElideRight
                                color: Colorscheme.current.on_surface
                            }

                            Text {
                                visible: WeatherService.hasData && WeatherService.city !== ''
                                text: WeatherService.city + ' · feels like ' + Math.round(WeatherService.feelsLikeC) + '°C'
                                font.pixelSize: 10
                                elide: Text.ElideRight
                                color: Colorscheme.current.on_surface_variant
                            }
                        }
                    }
                }

                // Notification history
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: {
                        let h = historyHeaderRow.implicitHeight + 20;
                        if (controlCenter.historyExpanded && NotificationsState.historyCount > 0)
                            h += historyList.height + 10;
                        return h;
                    }
                    radius: Config.general.radius
                    color: Colorscheme.current.surface_container

                    RowLayout {
                        id: historyHeaderRow
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 12
                        spacing: 8

                        Icon {
                            icon: 'notifications'
                            fill: true
                            size: 16
                            color: Colorscheme.current.on_surface
                        }

                        Text {
                            Layout.fillWidth: true
                            text: NotificationsState.historyCount > 0 ? 'Notifications (' + NotificationsState.historyCount + ')' : 'No notifications'
                            font.pixelSize: 12
                            font.bold: true
                            color: Colorscheme.current.on_surface
                        }

                        Rectangle {
                            visible: NotificationsState.historyCount > 0 && controlCenter.historyExpanded
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            radius: 12
                            color: clearMa.containsMouse ? Colorscheme.current.error_container : 'transparent'
                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }

                            Icon {
                                icon: 'delete'
                                size: 15
                                fill: true
                                anchors.centerIn: parent
                                color: clearMa.containsMouse ? Colorscheme.current.on_error_container : Colorscheme.current.on_surface_variant
                            }

                            MouseArea {
                                id: clearMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    NotificationsState.clearHistory();
                                    controlCenter.historyExpanded = false;
                                }
                            }
                        }

                        Rectangle {
                            visible: NotificationsState.historyCount > 0
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            radius: 12
                            color: chevronMa.containsMouse ? Colorscheme.current.surface_container_high : 'transparent'
                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }

                            Icon {
                                icon: 'expand_more'
                                size: 16
                                anchors.centerIn: parent
                                rotation: controlCenter.historyExpanded ? 180 : 0
                                color: Colorscheme.current.on_surface

                                Behavior on rotation {
                                    NumberAnimation {
                                        duration: 200
                                    }
                                }
                            }

                            MouseArea {
                                id: chevronMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: controlCenter.historyExpanded = !controlCenter.historyExpanded
                            }
                        }
                    }

                    readonly property int _entryHeight: 48
                    readonly property int _entrySpacing: 4
                    readonly property int _maxVisibleEntries: 6

                    ListView {
                        id: historyList
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: historyHeaderRow.bottom
                        anchors.topMargin: 10
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        visible: controlCenter.historyExpanded && NotificationsState.historyCount > 0
                        clip: true
                        spacing: parent._entrySpacing
                        boundsBehavior: Flickable.StopAtBounds

                        height: Math.min(NotificationsState.historyCount * (parent._entryHeight + parent._entrySpacing) - parent._entrySpacing, parent._maxVisibleEntries * (parent._entryHeight + parent._entrySpacing) - parent._entrySpacing)

                        model: NotificationsState.history
                        delegate: NotificationHistoryEntry {
                            required property var modelData
                            required property int index

                            width: historyList.width
                            entry: modelData
                            now: controlCenter._historyNow
                            onRemoveRequested: NotificationsState.removeHistoryAt(index)
                        }
                    }

                    Behavior on Layout.preferredHeight {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                Timer {
                    interval: 30000
                    running: controlCenter.active
                    repeat: true
                    onTriggered: controlCenter._historyNow = Date.now()
                }
            }
        }

        Corner {
            side: Corner.Side.TopLeft
            color: Colorscheme.current.surface
            Layout.alignment: Qt.AlignTop
        }
    }

    Timer {
        id: _volumeDebounce
        property real pendingValue: 0
        interval: 60
        onTriggered: VolumeService.setVolume(pendingValue)
    }

    Timer {
        id: _brightnessDebounce
        property real pendingValue: 0
        interval: 60
        onTriggered: BrightnessService.setScreen(pendingValue)
    }
}
