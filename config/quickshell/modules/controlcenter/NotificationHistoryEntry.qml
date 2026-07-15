pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

Rectangle {
    id: root

    required property var entry
    required property real now

    signal removeRequested

    readonly property string relativeTime: {
        const diffMs = root.now - root.entry.timestamp;
        const mins = Math.floor(diffMs / 60000);

        if (mins < 1)
            return 'now';
        if (mins < 60)
            return mins + 'm';

        const hours = Math.floor(mins / 60);
        if (hours < 24)
            return hours + 'h';

        return Math.floor(hours / 24) + 'd';
    }

    width: parent.width
    height: 48
    radius: Config.general.radius
    color: rowMa.containsMouse ? Colorscheme.current.surface_container_high : 'transparent'
    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    MouseArea {
        id: rowMa
        anchors.fill: parent
        hoverEnabled: true
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 6
        spacing: 8

        Rectangle {
            Layout.preferredWidth: 26
            Layout.preferredHeight: 26
            radius: 6
            color: Colorscheme.current.surface_container_high
            clip: true

            Image {
                visible: root.entry.iconSrc !== ''
                anchors.fill: parent
                source: root.entry.iconSrc
                fillMode: Image.PreserveAspectFit
                sourceSize: Qt.size(26, 26)
                asynchronous: true
            }

            Text {
                visible: root.entry.iconSrc === ''
                anchors.centerIn: parent
                text: root.entry.appName.charAt(0).toUpperCase()
                font.pixelSize: 12
                font.bold: true
                color: Colorscheme.current.on_surface_variant
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    Layout.fillWidth: true
                    text: root.entry.appName
                    font.pixelSize: 11
                    font.bold: true
                    elide: Text.ElideRight
                    color: Colorscheme.current.on_surface
                }

                Text {
                    text: root.relativeTime
                    font.pixelSize: 10
                    color: Colorscheme.current.on_surface_variant
                }
            }

            Text {
                Layout.fillWidth: true
                visible: root.entry.summary !== ''
                text: root.entry.summary
                font.pixelSize: 11
                elide: Text.ElideRight
                color: Colorscheme.current.on_surface_variant
            }
        }

        Rectangle {
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
            radius: 11
            color: closeMa.containsMouse ? Colorscheme.current.error_container : 'transparent'
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            Icon {
                icon: 'close'
                size: 13
                anchors.centerIn: parent
                color: closeMa.containsMouse ? Colorscheme.current.on_error_container : Colorscheme.current.on_surface_variant
            }

            MouseArea {
                id: closeMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.removeRequested()
            }
        }
    }
}
