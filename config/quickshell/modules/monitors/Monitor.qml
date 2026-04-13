pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.config

PanelWindow {
    id: win

    visible: MonitorState.open
    focusable: true
    color: 'transparent'

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: Config.appName + '-monitors'
    WlrLayershell.keyboardFocus: {
        if (MonitorState.open)
            return WlrKeyboardFocus.Exclusive;
        return WlrKeyboardFocus.None;
    }

    Rectangle {
        anchors.fill: parent
        color: 'black'

        opacity: MonitorState.open ? 0.65 : 0.0
        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }
    }

    MonitorPanel {
        anchors.centerIn: parent
        width: Math.min(parent.width - 40, 1100)
        height: Math.min(parent.height - 40, 780)

        Keys.onEscapePressed: {
            if (!MonitorState.hasDirtyOutputs())
                MonitorState.close();
        }
    }
}
