import QtQuick
import QtQuick.Layouts
import qs.config

Rectangle {
    id: root

    required property string icon
    property string label: ''
    property bool active: false

    signal clicked

    implicitHeight: 56
    radius: Config.general.radius

    color: {
        if (active)
            return Colorscheme.current.primary_container;
        if (ma.containsMouse)
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
        anchors.margins: 10
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
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
