pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.config

GridView {
    id: root

    signal launch(int index)

    clip: true
    currentIndex: -1

    readonly property int cols: Config.launcher.gridColumns
    cellWidth: Math.floor(width / cols)
    cellHeight: cellWidth

    highlightFollowsCurrentItem: true
    highlightMoveDuration: 200
    highlight: Rectangle {
        color: Colorscheme.current.surface_container_high
        radius: 8
    }

    delegate: Item {
        id: entry
        required property var modelData
        required property int index

        width: root.cellWidth
        height: root.cellHeight

        Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            radius: 8
            color: 'transparent'

            Column {
                anchors.centerIn: parent
                spacing: 6

                Image {
                    id: icon
                    width: 36
                    height: 36
                    anchors.horizontalCenter: parent.horizontalCenter
                    sourceSize: Qt.size(36, 36)
                    source: Quickshell.iconPath(entry.modelData.icon) || ''

                    Rectangle {
                        anchors.fill: parent
                        color: Colorscheme.current.primary
                        radius: 6
                        visible: icon.source === '' || icon.status === Image.Error

                        Text {
                            anchors.centerIn: parent
                            text: entry.modelData.name.charAt(0).toUpperCase()
                            color: Colorscheme.current.on_primary
                            font.pixelSize: 16
                            font.bold: true
                        }
                    }
                }

                Text {
                    width: root.cellWidth - 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: entry.modelData.name
                    color: Colorscheme.current.on_surface
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    maximumLineCount: 2
                    wrapMode: Text.WordWrap
                }
            }

            MouseArea {
                id: ma
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: root.currentIndex = entry.index
                onClicked: {
                    root.currentIndex = entry.index;
                    root.launch(entry.index);
                }
            }
        }
    }
}
