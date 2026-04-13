pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.components
import qs.services

Item {
    id: root

    signal wallpaperSelected(path: string)

    // empty / loading state
    Column {
        anchors.centerIn: parent
        spacing: 5
        visible: WallpaperService.wallpapers.length === 0

        Icon {
            anchors.horizontalCenter: parent.horizontalCenter
            icon: WallpaperService.scanning ? 'refresh' : 'image'
            size: 32
            color: Colorscheme.current.on_surface
            opacity: 0.4

            RotationAnimator on rotation {
                running: WallpaperService.scanning
                from: 0
                to: 360
                duration: 1200
                loops: Animation.Infinite
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: Colorscheme.current.on_surface
            opacity: 0.4
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            text: {
                if (WallpaperService.scanning)
                    return 'Loading…';

                return 'No wallpapers found in\n' + WallpaperService.wallpaperDir;
            }
        }
    }

    // wallpaper grid
    GridView {
        id: grid

        readonly property int cols: 2

        anchors.fill: parent
        visible: WallpaperService.wallpapers.length > 0
        model: WallpaperService.wallpapers
        clip: true

        cellWidth: Math.floor(width / cols)
        cellHeight: Math.floor(cellWidth * 9 / 16)

        delegate: Item {
            id: cell

            required property string modelData
            required property int index

            readonly property string fileUrl: 'file://' + cell.modelData
            readonly property bool isActive: cell.fileUrl === Config.wallpaper.source

            width: grid.cellWidth
            height: grid.cellHeight

            Rectangle {
                id: frame
                anchors.fill: parent
                anchors.margins: 4
                color: Colorscheme.current.surface_container_high
                clip: true

                // wallpaper image
                Image {
                    id: thumb
                    anchors.fill: parent
                    source: cell.fileUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true

                    opacity: status === Image.Ready ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }

                Icon {
                    icon: 'refresh'
                    anchors.centerIn: parent
                    visible: thumb.status !== Image.Ready
                    color: Colorscheme.current.on_surface
                    opacity: 0.3
                }

                // active indicator
                Rectangle {
                    anchors.fill: parent
                    radius: frame.radius
                    color: 'transparent'
                    border.color: Colorscheme.current.primary
                    border.width: cell.isActive ? 3 : 0
                    Behavior on border.width {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }

                Rectangle {
                    visible: cell.isActive

                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 6

                    width: 20
                    height: 20
                    radius: 10
                    color: Colorscheme.current.primary

                    Icon {
                        icon: 'check'
                        anchors.centerIn: parent
                        color: Colorscheme.current.on_primary
                    }
                }

                // hover
                Rectangle {
                    anchors.fill: parent
                    opacity: 0.35

                    color: cellMa.containsMouse ? 'black' : 'transparent'
                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }

                MouseArea {
                    id: cellMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.wallpaperSelected(cell.fileUrl)
                }
            }
        }
    }
}
