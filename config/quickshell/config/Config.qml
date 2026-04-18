pragma Singleton

import Quickshell
import Quickshell.Io
import QtCore
import QtQuick

Singleton {
    id: root

    readonly property string shellName: 'shell'

    readonly property string configPath: Paths.config + '/' + shellName
    readonly property string cachePath: Paths.cache + '/' + shellName

    readonly property alias general: adapter.general
    readonly property alias colors: adapter.colors
    readonly property alias lockscreen: adapter.lockscreen
    readonly property alias launcher: adapter.launcher
    readonly property alias osd: adapter.osd
    readonly property alias wallpaper: adapter.wallpaper
    readonly property alias wallpaperGeneratingFg: wallpaperFgGenerator.running

    FileView {
        path: root.configPath + '/config.json'
        watchChanges: true

        onAdapterUpdated: this.writeAdapter()
        onFileChanged: this.reload()
        onLoadFailed: err => {
            if (err == FileViewError.FileNotFound)
                this.writeAdapter();
        }

        adapter: JsonAdapter {
            id: adapter

            property JsonObject general: JsonObject {
                property int radius: 10
            }

            property JsonObject colors: JsonObject {
                // Enable dynamic color scheme based on wallpaper colors.
                property bool dynamic: true

                // This option specifies the color scheme mode
                //
                // Possible values are:
                //     'light' - Use light color scheme
                //     'dark' - Use dark color scheme
                property string scheme: 'dark'
            }

            property JsonObject wallpaper: JsonObject {
                // This option enables support for layered wallpapers.
                //
                // Layered wallpapers split the background and foreground elements into
                // different layers, allowing for more dynamic and visually appealing.
                //
                // When enabled, the wallpaper system will generate the foreground from
                // wallpaper and render it on a separate layer above the background.
                property bool layered: true

                // Path to the wallpaper image
                //
                // Note: this is now empty to force wallpaper foreground generation
                // even on startup.
                property string source

                // Path to wallpaper foreground image
                property string foreground

                // Restart generators if needed when wallpaper source changes
                onSourceChanged: {
                    if (source !== '' && colors.dynamic && !colorsGenerator.running) {
                        colorsGenerator.wallpaperSource = source;
                        colorsGenerator.running = true;
                    }

                    if (source !== '' && layered && !wallpaperFgGenerator.running) {
                        wallpaperFgGenerator.wallpaperSource = source;
                        wallpaperFgGenerator.running = true;
                    }
                }
            }

            property JsonObject lockscreen: JsonObject {
                property JsonObject clock: JsonObject {
                    // Scale of the clock on the lock screen
                    property real scale: 1.0

                    // Position of the clock on the lock screen
                    property JsonObject pos: JsonObject {
                        property real x: -1
                        property real y: -1
                    }
                }
            }

            property JsonObject launcher: JsonObject {
                property JsonObject terminal: JsonObject {
                    // Terminal emulator used to launch apps with runInTerminal: true
                    // The '-e' flag is standard for most terminals (foot, alacritty, kitty, xterm...)
                    property string exec: 'foot'
                    property string execFlag: '-e'
                }

                // Launcher height as a fraction of the screen height (0.0 - 1.0)
                property real heightFraction: 0.75

                // Possible values: 'grid' or 'list'
                property string viewMode: 'list'

                // Grid columns (only used when viewMode is 'grid')
                property int gridColumns: 3

                // Path to wallpapers
                property string wallpaperDir: {
                    const pictures = StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0];
                    return pictures.toString().slice(7) + "/wallpapers";
                }
            }

            property JsonObject osd: JsonObject {
                // Time in milliseconds before the OSD hides automatically
                property int hideTimeout: 2000

                // Width of the progress bar (volume/brightness)
                property int barWidth: 10

                // Size of the Material Symbols icon
                property int iconSize: 18

                // Margins around the content inside the OSD panel
                property int contentMargins: 10

                // Panel height as a fraction of the screen height (0.0 - 1.0)
                property real heightFraction: 0.25

                // Corner radius of the OSD panel
                property int radius: 10
            }
        }
    }

    Process {
        id: colorsGenerator
        property string wallpaperSource

        command: {
            const script = Paths.url2Path(Qt.resolvedUrl('../scripts/colorsGenerator'));
            const wallpaper = Paths.url2Path(wallpaperSource);
            const outputPath = Paths.url2Path(root.configPath + '/colors.json');
            const cachePath = Paths.url2Path(root.cachePath);

            return [script, wallpaper, outputPath, cachePath];
        }
    }

    Process {
        id: wallpaperFgGenerator
        property string wallpaperSource

        command: {
            const script = Paths.url2Path(Qt.resolvedUrl('../scripts/rembg'));
            const wallpaper = Paths.url2Path(wallpaperSource);
            const outputPath = Paths.url2Path(root.cachePath);

            return [script, wallpaper, outputPath];
        }

        stdout: StdioCollector {
            onStreamFinished: {
                let text = this.text.trim();

                if (text === '')
                    return;

                if (text.startsWith('Error: ')) {
                    console.warn('Failed to generate wallpaper foreground:', text.substring(7));
                    return;
                }

                root.wallpaper.foreground = text;
            }
        }
    }
}
