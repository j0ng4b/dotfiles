pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.config
import qs.services

PanelWindow {
    id: win

    visible: MonitorState.open
    focusable: true
    color: 'transparent'

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: MonitorState.open
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None
    WlrLayershell.namespace: Config.appName + '-monitors'

    anchors.top:    true
    anchors.bottom: true
    anchors.left:   true
    anchors.right:  true

    Rectangle {
        anchors.fill: parent
        color: "black"

        opacity: MonitorState.open ? 0.65 : 0.0
        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }
    }
}
