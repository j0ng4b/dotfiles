pragma Singleton

import Quickshell
import QtQuick
import qs.config
import qs.services

Singleton {
    id: root

    property bool visible: false

    property string type: "volume"
    property real level: 0.0
    property bool muted: false

    readonly property string icon: {
        switch (type) {
            case "volume":
                if (muted || level === 0)
                    return "volume_off";
                if (level < 0.34)
                    return "volume_down";

                return "volume_up";

            case "brightness-screen":
                if (level < 0.34)
                    return "brightness_low";
                if (level < 0.67)
                    return "brightness_medium";

                return "brightness_high";

            case "brightness-kbd":
                return "keyboard";

            default:
                return "";
        }
    }

    function _show(t, v, m) {
        type    = t;
        level   = v;
        muted   = m ?? false;

        visible = true;
        hideTimer.restart();
    }

    Timer {
        id: hideTimer
        repeat: false
        interval: Config.osd.hideTimeout
        onTriggered: root.visible = false
    }

    Connections {
        target: Volume

        function onChanged() {
            root._show("volume", Volume.level, Volume.muted);
        }
    }

    Connections {
        target: Brightness

        function onChanged(source: string) {
            if (source == "screen" && Brightness.screen >= 0)
                root._show("brightness-screen", Brightness.screen);

            if (source == "keyboard" && Brightness.kbd >= 0)
                root._show("brightness-kbd", Brightness.kbd);
        }
    }
}
