pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property var current: {
        const base = Config.colors.scheme === 'dark' ? dark : light;
        return new Proxy(base, {
            get(target, key) {
                return key in target ? target[key] : 'transparent';
            }
        });
    }

    property var dark: ({})
    property var light: ({})

    function _parseSchemes() {
        const colors = colorsAdapter.colors;
        if (!colors)
            return;

        const dark = {}, light = {};
        for (const key in colors) {
            const entry = colors[key];
            if (entry?.dark?.color !== undefined)
                dark[key] = entry.dark.color;
            if (entry?.light?.color !== undefined)
                light[key] = entry.light.color;
        }

        root.dark = dark;
        root.light = light;
    }

    FileView {
        watchChanges: true
        path: Config.configPath + '/colors.json'

        onFileChanged: this.reload()
        onLoadFailed: err => console.warn("Colors: failed to load file:", err)

        JsonAdapter {
            id: colorsAdapter
            property var colors
            onColorsChanged: root._parseSchemes()
        }
    }
}
