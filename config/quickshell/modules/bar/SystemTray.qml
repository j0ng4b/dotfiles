import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.components

Rectangle {
    id: root

    implicitHeight: _row.implicitHeight + 8
    implicitWidth: _row.implicitWidth + 16
    radius: 6
    color: Colorscheme.current.surface_container

    RowLayout {
        id: _row
        anchors.centerIn: parent
        spacing: 10

        // Network
        BarIndicator {
            tooltipText: {
                if (NetworkService.ethernetEnabled)
                    return NetworkService.ethernetInterface;

                if (NetworkService.wifiEnabled && NetworkService.wifiName !== "")
                    return NetworkService.wifiName;

                return "offline";
            }

            content: Icon {
                icon: {
                    if (NetworkService.ethernetEnabled)
                        return "settings_ethernet";

                    if (!NetworkService.wifiEnabled)
                        return "wifi_off";

                    const sig = NetworkService.wifiSignalLevel;
                    if (sig >= -60)
                        return "wifi";

                    if (sig >= -70)
                        return "wifi_2_bar";

                    return "wifi_1_bar";
                }
                fill: NetworkService.ethernetEnabled || NetworkService.wifiEnabled
                size: 14
                color: {
                    const connected = NetworkService.ethernetEnabled ? NetworkService.ethernetState === "connected" : NetworkService.wifiState === "connected";

                    if (!NetworkService.ethernetEnabled && !NetworkService.wifiEnabled)
                        return Colorscheme.current.on_surface_variant;

                    if (!connected)
                        return Colorscheme.current.tertiary;

                    return Colorscheme.current.on_surface;
                }
            }
        }

        // Volume
        BarIndicator {
            tooltipText: VolumeService.muted ? "muted" : Math.round(VolumeService.level * 100) + "%"

            content: Icon {
                fill: true
                size: 14
                color: Colorscheme.current.on_surface
                icon: {
                    if (VolumeService.muted)
                        return "volume_off";

                    if (VolumeService.level > 0.6)
                        return "volume_up";

                    if (VolumeService.level > 0.15)
                        return "volume_down";

                    return "volume_mute";
                }
            }
        }

        // Battery
        BarIndicator {
            tooltipText: BatteryService.capacity + "%"

            content: Item {
                implicitWidth: _body.width + _bulb.width
                implicitHeight: _body.height

                Rectangle {
                    id: _body
                    width: 28
                    height: 14
                    radius: 3
                    color: "transparent"
                    border.color: _battColor()
                    border.width: 1.5

                    function _battColor() {
                        if (BatteryService.capacity <= 20)
                            return "#e05252";

                        if (BatteryService.capacity <= 50)
                            return "#e0a352";

                        return Colorscheme.current.on_surface;
                    }

                    Rectangle {
                        radius: 2
                        width: Math.max(0, (_body.width - 5) * (BatteryService.capacity / 100))
                        color: _body._battColor()
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                            margins: 2.5
                        }

                        Behavior on width {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.InOutQuad
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 300
                            }
                        }
                    }

                    Icon {
                        visible: BatteryService.state === BatteryService.State.Charging
                        anchors.horizontalCenter: parent.horizontalCenter
                        icon: "bolt"
                        fill: true
                        size: 10
                        color: BatteryService.capacity > 50 ? Colorscheme.current.surface : Colorscheme.current.on_surface
                    }
                }

                Rectangle {
                    id: _bulb
                    anchors.left: _body.right
                    anchors.verticalCenter: _body.verticalCenter
                    width: 3
                    height: 8
                    radius: 1
                    color: _body._battColor()
                }
            }
        }
    }
}
