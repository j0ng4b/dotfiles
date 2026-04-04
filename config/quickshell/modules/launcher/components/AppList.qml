import QtQuick
import Quickshell
import qs.config

ListView {
    id: root

    signal launch(int index)

    clip: true
    spacing: 2
    currentIndex: -1

    highlightFollowsCurrentItem: true
    highlightMoveDuration: 250
    highlightMoveVelocity: -1
    highlight: Rectangle {
        color: Colorscheme.current.surface_container_high
        radius: 6
    }

    delegate: Rectangle {
        id: entry
        required property var modelData
        required property int index

        width: root.width
        height: 40
        radius: 8
        color: "transparent"

        Row {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 10

            Image {
                id: icon
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                sourceSize: Qt.size(24, 24)
                source: Quickshell.iconPath(entry.modelData.icon) || ""

                Rectangle {
                    anchors.fill: parent
                    color: Colorscheme.current.primary
                    radius: 4
                    visible: icon.source === "" || icon.status === Image.Error

                    Text {
                        anchors.centerIn: parent
                        text: entry.modelData.name.charAt(0).toUpperCase()
                        color: Colorscheme.current.on_primary
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
            }

            Text {
                width: parent.width - 34
                anchors.verticalCenter: parent.verticalCenter
                text: entry.modelData.name
                color: Colorscheme.current.on_surface
                font.pixelSize: 13
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.currentIndex = index
            onClicked: {
                root.currentIndex = index;
                root.launch(index);
            }
        }
    }
}
