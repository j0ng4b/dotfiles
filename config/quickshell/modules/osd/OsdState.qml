pragma Singleton

import Quickshell
import QtQuick
import qs.config
import qs.services

Singleton {
    id: root

    property bool visible: false

    property string type: 'volume'
    property real level: 0.0
    property bool muted: false

    readonly property string icon: {
        switch (type) {
        case 'volume':
            if (muted)
                return VolumeService.type == 'speaker' ? 'volume_off' : 'headset_off';

            if (level > 0.6)
                return VolumeService.type == 'speaker' ? 'volume_up' : 'headset_mic';

            if (level > 0.15)
                return VolumeService.type == 'speaker' ? 'volume_down' : 'headset_mic';

            return VolumeService.type == 'speaker' ? 'volume_mute' : 'headset_mic';
        case 'brightness-screen':
            if (level < 0.34)
                return 'brightness_low';
            if (level < 0.67)
                return 'brightness_medium';

            return 'brightness_high';
        case 'brightness-kbd':
            return 'keyboard';
        default:
            return '';
        }
    }

    function _show(t, v, m) {
        type = t;
        level = v;
        muted = m ?? false;
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
        target: VolumeService
        function onChanged() {
            root._show('volume', VolumeService.level, VolumeService.muted);
        }
    }

    Connections {
        target: BrightnessService
        function onChanged(source: string) {
            if (source == 'screen' && BrightnessService.screen >= 0)
                root._show('brightness-screen', BrightnessService.screen);

            if (source == 'keyboard' && BrightnessService.kbd >= 0)
                root._show('brightness-kbd', BrightnessService.kbd);
        }
    }
}
