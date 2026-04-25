import QtQuick
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
            radius: 1.5
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                margins: 2.5
            }

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
    }

    // Tooltip
    Item {
        id: tooltip
        visible: _hover.containsMouse
        opacity: visible ? 1 : 0

        z: 100
        anchors.top: body.bottom
        anchors.topMargin: 8
        anchors.horizontalCenter: body.horizontalCenter

        Behavior on opacity { NumberAnimation { duration: 150 } }

        Rectangle {
            id: triangle
            width: 8; height: 8
            color: Colorscheme.current.on_surface
            rotation: 45
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: -4
        }

        Rectangle {
            id: labelBox
            width: _label.implicitWidth + 12
            height: _label.implicitHeight + 4
            anchors.top: triangle.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 4
            color: Colorscheme.current.on_surface

            Text {
                id: _label
                text: BatteryService.capacity + '%'
                anchors.centerIn: parent
                font.pixelSize: 10
                font.bold: true
                color: Colorscheme.current.surface
            }
        }
    }

    MouseArea {
        id: _hover
        anchors.fill: parent
        hoverEnabled: true
    }
}
