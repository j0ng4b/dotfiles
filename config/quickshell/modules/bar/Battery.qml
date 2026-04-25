import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.components

Item {
    id: root

    implicitWidth: body.width + bulb.width
    implicitHeight: body.height

    // Battery body
    Rectangle {
        id: body
        width: 28
        height: 14
        radius: 3
        color: "transparent"
        border.color: fillColor()
        border.width: 1.5

        function fillColor() {
            if (BatteryService.capacity <= 20)
                return "#e05252";

            if (BatteryService.capacity <= 50)
                return "#e0a352";

            return Colorscheme.current.on_surface;
        }

        Rectangle {
            id: fill
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 2.5
            radius: 1.5

            width: Math.max(0, (body.width - 5) * (BatteryService.capacity / 100))

            color: body.fillColor()

            Behavior on width {
                NumberAnimation {
                    duration: 300;
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 300
                }
            }
        }

        // Charging icon
        Icon {
            visible: BatteryService.state === BatteryService.State.Charging
            anchors.centerIn: parent
            icon: "bolt"
            fill: true
            size: 10
            color: {
                if (BatteryService.capacity > 50)
                    return Colorscheme.current.surface;
                return Colorscheme.current.on_surface;
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }
        }
    }

    // Nub
    Rectangle {
        id: bulb
        anchors.left: body.right
        anchors.verticalCenter: body.verticalCenter

        width: 3
        height: 8
        radius: 1
        color: body.fillColor()

        Behavior on color {
            ColorAnimation { duration: 300 }
        }
    }
}
