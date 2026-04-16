pragma Singleton

import Quickshell

Singleton {
    readonly property url cache: Quickshell.env("XDG_CACHE_HOME") || Quickshell.env("HOME") + "/.cache"
    readonly property url config: Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config"

    function url2Path(url) {
        if (url === undefined || url === null)
            return '';
        return url.toString().replace('file://', '');
    }
}
