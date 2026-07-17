import QtQuick
import QtQuick.Layouts
import qs.modules.notifications
import qs.config
import qs.components
import qs.services

Item {
    id: root

    signal wifiPageRequested

    implicitHeight: content.implicitHeight + 32

    ColumnLayout {
        id: content

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 16

        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            QuickToggle {
                Layout.fillWidth: true

                label: {
                    if (!NetworkService.wifiEnabled)
                        return "Off";
                    return NetworkService.wifiName !== "" ? NetworkService.wifiName : "On";
                }

                icon: NetworkService.wifiEnabled ? "wifi" : "wifi_off"
                active: NetworkService.wifiEnabled
                showChevron: true
                onClicked: NetworkService.wifiToggle()
                onChevronClicked: root.wifiPageRequested()
            }

            QuickToggle {
                Layout.fillWidth: true

                label: {
                    if (!BluetoothService.enabled)
                        return "Off";

                    return BluetoothService.connected ? BluetoothService.deviceName : "On";
                }

                icon: BluetoothService.enabled ? "bluetooth" : "bluetooth_disabled"
                active: BluetoothService.enabled
                onClicked: BluetoothService.toggle()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            QuickToggle {
                Layout.fillWidth: true

                icon: ColorTemperatureService.isNight ? "dark_mode" : "light_mode"
                label: ColorTemperatureService.isNight ? "Night" : "Day"
                active: ColorTemperatureService.isNight
                onClicked: ColorTemperatureService.toggle()
            }

            QuickToggle {
                Layout.fillWidth: true

                icon: NotificationsState.dnd ? "notifications_off" : "notifications"
                label: NotificationsState.dnd ? "DND On" : "DND Off"
                active: NotificationsState.dnd
                onClicked: NotificationsState.toggleDnd()
            }
        }

        Slider {
            Layout.fillWidth: true

            icon: {
                if (VolumeService.muted)
                    return "volume_off";
                if (VolumeService.level > 0.6)
                    return "volume_up";
                if (VolumeService.level > 0.15)
                    return "volume_down";
                return "volume_mute";
            }
            onIconClicked: VolumeService.toggleMute()

            value: VolumeService.level
            onMoved: value => {
                volumeDebounce.pendingValue = value;
                volumeDebounce.restart();
            }
        }

        Slider {
            Layout.fillWidth: true

            icon: {
                if (BrightnessService.screen < 0.34)
                    return "brightness_low";
                if (BrightnessService.screen < 0.67)
                    return "brightness_medium";
                return "brightness_high";
            }

            value: Math.max(0, BrightnessService.screen)
            onMoved: value => {
                brightnessDebounce.pendingValue = value;
                brightnessDebounce.restart();
            }
        }

        // Weather
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

                    icon: WeatherService.loading ? "refresh" : WeatherService.icon
                    fill: true
                    size: 22
                    color: Colorscheme.current.primary

                    RotationAnimator on rotation {
                        running: WeatherService.loading
                        from: 0
                        to: 360
                        duration: 1200
                        loops: Animation.Infinite
                    }

                    Connections {
                        target: WeatherService

                        function onLoadingChanged() {
                            if (!WeatherService.loading)
                                weatherIcon.rotation = 0;
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        Layout.fillWidth: true

                        text: {
                            if (!WeatherService.hasData)
                                return "Weather unavailable";

                            return Math.round(WeatherService.tempC) + "°C · " + WeatherService.description;
                        }

                        font.pixelSize: 12
                        font.bold: true
                        elide: Text.ElideRight
                        color: Colorscheme.current.on_surface
                    }

                    Text {
                        Layout.fillWidth: true

                        visible: WeatherService.hasData && WeatherService.city !== ""
                        text: WeatherService.city + " · feels like " + Math.round(WeatherService.feelsLikeC) + "°C"
                        font.pixelSize: 10
                        elide: Text.ElideRight
                        color: Colorscheme.current.on_surface_variant
                    }
                }
            }
        }
    }

    Timer {
        id: volumeDebounce

        property real pendingValue: 0

        interval: 60
        onTriggered: VolumeService.setVolume(pendingValue)
    }

    Timer {
        id: brightnessDebounce

        property real pendingValue: 0

        interval: 60
        onTriggered: BrightnessService.setScreen(pendingValue)
    }
}
