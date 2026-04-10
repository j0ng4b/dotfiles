import QtQuick
import qs.config
import qs.services

Rectangle {
    id: indicator
    required property var modelData

    color: modelData.active
        ? Colorscheme.current.primary
        : Colorscheme.current.surface_container_high;

    Behavior on color  { ColorAnimation  { duration: 200 } }
    Behavior on width { NumberAnimation { duration: 100 } }

    implicitWidth: 20 + (modelData.active ? 10 : 0)
    implicitHeight: 8
    radius: Config.general.radius

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onClicked: {
            NiriService.focusWorkspace(indicator.modelData.index);
        }
    }
}
