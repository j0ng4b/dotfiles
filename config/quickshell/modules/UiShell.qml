pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.config
import qs.modules.bar
import qs.modules.launcher
import qs.modules.osd

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: shell
        required property var modelData
        screen: modelData

        color: 'transparent'

        anchors.top: true
        exclusiveZone: bar.contentHeight

        implicitWidth: screen.width
        implicitHeight: screen.height

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: Config.shellName + '-ui'
        WlrLayershell.keyboardFocus: {
            if (launcher.active)
                return WlrKeyboardFocus.Exclusive;
            return WlrKeyboardFocus.None;
        }

        mask: Region {
            regions: [osd.mask, launcher.mask, bar.mask]
        }

        // Declaration order == paint order, from bottom (first) to top (last)
        Osd {
            id: osd
            screen: shell.screen
        }

        Launcher {
            id: launcher
            screen: shell.screen
        }

        Bar {
            id: bar
            screen: shell.screen
        }
    }
}
