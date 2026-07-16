import QtQuick
import QtQuick.Layouts
import qs.config

Rectangle {
    id: root

    required property string icon
    property string label: ''
    property bool active: false
    property bool showChevron: false

    signal clicked
    signal chevronClicked

    implicitHeight: 56
    radius: Config.general.radius

    color: {
        if (active)
            return Colorscheme.current.primary_container;
        if (bodyMa.containsMouse)
            return Colorscheme.current.surface_container_high;
        return Colorscheme.current.surface_container;
    }
    Behavior on color {
        ColorAnimation {
            duration: 200
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Body
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: root.showChevron ? 6 : 10
                spacing: 8

                Icon {
                    icon: root.icon
                    fill: root.active
                    color: root.active ? Colorscheme.current.on_primary_container : Colorscheme.current.on_surface
                }

                Text {
                    Layout.fillWidth: true
                    text: root.label
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    color: root.active ? Colorscheme.current.on_primary_container : Colorscheme.current.on_surface
                }
            }

            MouseArea {
                id: bodyMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.clicked()
            }
        }

        // Separator
        Rectangle {
            visible: root.showChevron
            Layout.preferredWidth: 1
            Layout.preferredHeight: parent.height / 2
            Layout.alignment: Qt.AlignVCenter
            color: root.active ? Colorscheme.current.on_primary_container : Colorscheme.current.on_surface
            opacity: 0.3
        }

        // Chevron
        Item {
            visible: root.showChevron
            Layout.preferredWidth: 34
            Layout.fillHeight: true

            Icon {
                icon: 'chevron_right'
                size: 16
                anchors.centerIn: parent
                color: root.active ? Colorscheme.current.on_primary_container : Colorscheme.current.on_surface
                opacity: chevronMa.containsMouse ? 1.0 : 0.5
            }

            MouseArea {
                id: chevronMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.chevronClicked()
            }
        }
    }
}
