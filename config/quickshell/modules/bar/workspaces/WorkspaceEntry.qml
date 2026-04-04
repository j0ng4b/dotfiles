import QtQuick
import qs.config
import qs.services

Rectangle {
    id: indicator
    required property var modelData

    implicitWidth: 18 + (modelData.active ? 6 : 0)
    implicitHeight: 8
    color: modelData.active ? Colorscheme.current.primary : Colorscheme.current.surface_container_high
    radius: 10

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onClicked: {
            Niri.focusWorkspace(indicator.modelData.index);
        }
    }
}
