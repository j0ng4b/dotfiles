import QtQuick
import qs.config

Item {
    id: root

    property string tooltipText: ""
    property alias content: _contentSlot.data

    implicitWidth: _contentSlot.implicitWidth
    implicitHeight: _contentSlot.implicitHeight

    // Slot
    Item {
        id: _contentSlot
        anchors.centerIn: parent
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
    }

    // Tooltip
    Item {
        id: tooltip
        visible: _hover.containsMouse && root.tooltipText !== ""
        opacity: visible ? 1 : 0
        z: 100
        anchors.top: parent.bottom
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }

        Rectangle {
            width: 8
            height: 8
            color: Colorscheme.current.on_surface
            rotation: 45
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: -4
        }

        Rectangle {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: _tipLabel.implicitWidth + 12
            height: _tipLabel.implicitHeight + 6
            radius: 4
            color: Colorscheme.current.on_surface

            Text {
                id: _tipLabel
                anchors.centerIn: parent
                text: root.tooltipText
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
