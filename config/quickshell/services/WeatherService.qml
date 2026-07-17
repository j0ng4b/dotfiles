pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.config

Singleton {
    id: root

    readonly property string scriptPath: Paths.url2Path(Qt.resolvedUrl("../scripts/scripter"))

    property bool loading: false
    property bool hasData: false

    property real tempC: 0
    property real feelsLikeC: 0
    property string description: ''
    property string city: ''
    property int code: 0

    readonly property string icon: {
        switch (root.code) {
        case 113:
            return 'clear_day';
        case 116:
            return 'partly_cloudy_day';
        case 119:
        case 122:
            return 'cloud';
        case 143:
        case 248:
        case 260:
            return 'foggy';
        case 176:
        case 263:
        case 266:
        case 293:
        case 296:
        case 299:
        case 302:
        case 305:
        case 308:
        case 311:
        case 314:
        case 317:
        case 353:
        case 356:
        case 359:
            return 'rainy';
        case 179:
        case 182:
        case 185:
        case 227:
        case 230:
        case 281:
        case 284:
        case 320:
        case 323:
        case 326:
        case 329:
        case 332:
        case 335:
        case 338:
        case 350:
        case 362:
        case 365:
        case 368:
        case 371:
        case 374:
        case 377:
        case 392:
        case 395:
            return 'weather_snowy';
        case 200:
        case 386:
        case 389:
            return 'thunderstorm';
        default:
            return 'device_thermostat';
        }
    }

    function refresh() {
        if (_fetcher.running)
            return;

        root.loading = true;
        _fetcher.running = true;
    }

    Timer {
        // Run every 10 minutes
        interval: 10 * (60 * 1000)
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: _fetcher
        running: false
        command: [root.scriptPath, "weather", "status"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.loading = false;
                try {
                    const json = JSON.parse(this.text.trim());
                    root.tempC = parseFloat(json.temp_c);
                    root.feelsLikeC = parseFloat(json.feels_like_c);
                    root.description = json.description ?? '';
                    root.city = json.city ?? '';
                    root.code = parseInt(json.code) || 0;
                    root.hasData = true;
                } catch (e) {
                    console.warn("Weather: parse error:", e);
                }
            }
        }
    }
}
