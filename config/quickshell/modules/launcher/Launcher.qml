pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.components
import qs.services
import qs.modules.launcher.components

Item {
    id: launcher

    required property var screen

    readonly property bool active: LauncherState.isOpen(launcher.screen.name)
    property list<DesktopEntry> filtered: entries

    readonly property bool isGrid: Config.launcher.viewMode === 'grid'
    readonly property int tabIndex: LauncherState.activeTab === 'wallpapers' ? 1 : 0
    readonly property int animationDuration: 300
    readonly property list<DesktopEntry> entries: DesktopEntries.applications.values

    readonly property int implicitWidth: 320
    readonly property int implicitHeight: Math.round(launcher.height * Config.launcher.heightFraction)

    readonly property var mask: Region {
        Region {
            width: launcher.active ? launcher.width : 0
            height: launcher.active ? launcher.height : 0
        }

        Region {
            item: container
        }
    }

    enabled: launcher.active
    anchors.fill: parent

    onActiveChanged: {
        if (active) {
            searchBar.clear();
            launcher.filter();
        } else {
            hideTimer.restart();
        }
    }

    // Click outside the panel closes it
    MouseArea {
        anchors.fill: parent
        enabled: launcher.active
        onClicked: LauncherState.close()
    }

    Item {
        id: container

        width: launcher.implicitWidth
        height: cornerTop.size + panel.height + cornerBottom.size

        anchors.verticalCenter: parent.verticalCenter

        x: launcher.active ? 0 : -launcher.implicitWidth
        Behavior on x {
            NumberAnimation {
                duration: launcher.animationDuration
                easing.type: launcher.active ? Easing.OutCubic : Easing.InCubic
            }
        }

        // Blocks clicks on the panel itself from reaching the outside-click
        // MouseArea behind it.
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Corner {
            id: cornerTop
            anchors.bottom: panel.top
            side: Corner.Side.BottomLeft
            color: Colorscheme.current.surface
        }

        Rectangle {
            id: panel
            color: Colorscheme.current.surface
            width: launcher.implicitWidth
            height: launcher.implicitHeight - cornerTop.size - cornerBottom.size
            anchors.top: cornerTop.bottom
            topRightRadius: Config.general.radius
            bottomRightRadius: Config.general.radius

            ColumnLayout {
                spacing: 8
                anchors.fill: parent
                anchors.margins: 20

                // Tabs
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36

                    Rectangle {
                        anchors.fill: parent
                        radius: Config.general.radius
                        color: Colorscheme.current.surface_container_high
                    }

                    Rectangle {
                        id: activePill

                        width: (parent.width - 6) / 2
                        height: parent.height - 6
                        radius: Config.general.radius - 2
                        color: Colorscheme.current.primary

                        anchors.verticalCenter: parent.verticalCenter

                        x: launcher.tabIndex === 0 ? 3 : width + 3
                        Behavior on x {
                            NumberAnimation {
                                duration: 220
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 3
                        spacing: 8

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6

                                Icon {
                                    icon: 'grid_view'
                                    fill: launcher.tabIndex === 0

                                    color: launcher.tabIndex === 0 ? Colorscheme.current.on_primary : Colorscheme.current.on_surface
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 180
                                        }
                                    }
                                }

                                Text {
                                    text: 'Apps'
                                    font.pixelSize: 14

                                    color: launcher.tabIndex === 0 ? Colorscheme.current.on_primary : Colorscheme.current.on_surface
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 180
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: LauncherState.switchTab('apps')
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6

                                Icon {
                                    icon: 'wallpaper'
                                    fill: launcher.tabIndex === 1

                                    color: launcher.tabIndex === 1 ? Colorscheme.current.on_primary : Colorscheme.current.on_surface
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 180
                                        }
                                    }
                                }

                                Text {
                                    text: 'Wallpapers'
                                    font.pixelSize: 14

                                    color: launcher.tabIndex === 1 ? Colorscheme.current.on_primary : Colorscheme.current.on_surface
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 180
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: LauncherState.switchTab('wallpapers')
                            }
                        }
                    }
                }

                Item {
                    id: viewport

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Row {
                        id: contentStrip

                        width: viewport.width * 2
                        height: viewport.height

                        x: launcher.tabIndex === 0 ? 0 : -viewport.width
                        Behavior on x {
                            NumberAnimation {
                                duration: 260
                                easing.type: Easing.OutCubic

                                onRunningChanged: {
                                    if (!running && launcher.tabIndex === 1)
                                        WallpaperService.rescan();
                                }
                            }
                        }

                        // Apps tab
                        Item {
                            x: 0
                            width: viewport.width
                            height: viewport.height

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 8

                                // Search bar
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    SearchBar {
                                        id: searchBar
                                        Layout.fillWidth: true

                                        onTextChanged: launcher.filter()
                                        onClose: LauncherState.close()
                                        onConfirm: launcher.launchSelected()
                                        onMoveUp: launcher.isGrid ? gridView.moveCurrentIndexUp() : listView.decrementCurrentIndex()
                                        onMoveDown: launcher.isGrid ? gridView.moveCurrentIndexDown() : listView.incrementCurrentIndex()
                                        onMoveLeft: if (launcher.isGrid)
                                            gridView.moveCurrentIndexLeft()
                                        onMoveRight: if (launcher.isGrid)
                                            gridView.moveCurrentIndexRight()
                                        onTab: launcher.tabNext()
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 36
                                        Layout.preferredHeight: 36
                                        radius: 8

                                        color: viewToggle.containsMouse ? Colorscheme.current.surface_variant : Colorscheme.current.surface_container_high
                                        Behavior on color {
                                            ColorAnimation {
                                                duration: 100
                                            }
                                        }

                                        Icon {
                                            icon: launcher.isGrid ? 'list' : 'grid_view'
                                            fill: viewToggle.containsMouse
                                            anchors.centerIn: parent
                                            color: Colorscheme.current.on_surface
                                        }

                                        MouseArea {
                                            id: viewToggle
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: Config.launcher.viewMode = launcher.isGrid ? 'list' : 'grid'
                                        }
                                    }
                                }

                                AppList {
                                    id: listView
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    visible: !launcher.isGrid
                                    model: launcher.filtered
                                    onLaunch: launcher.launchSelected()
                                }

                                AppGrid {
                                    id: gridView
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    visible: launcher.isGrid
                                    model: launcher.filtered
                                    onLaunch: launcher.launchSelected()
                                }
                            }
                        }

                        // Wallpapers tab
                        WallpaperSelector {
                            width: viewport.width
                            height: viewport.height

                            onWallpaperSelected: path => {
                                Config.wallpaper.source = Qt.resolvedUrl(path);
                            }
                        }
                    }
                }
            }
        }

        Corner {
            id: cornerBottom
            anchors.top: panel.bottom
            side: Corner.Side.TopLeft
            color: Colorscheme.current.surface
        }
    }

    function tabNext() {
        if (isGrid) {
            const next = gridView.currentIndex + 1;
            gridView.currentIndex = next >= filtered.length ? 0 : next;
        } else {
            const next = listView.currentIndex + 1;
            listView.currentIndex = next >= filtered.length ? 0 : next;
        }
    }

    function filter() {
        const q = searchBar.text.toLowerCase().trim();
        filtered = entries.filter(a => q === '' || a.name.toLowerCase().includes(q));

        listView.currentIndex = -1;
        gridView.currentIndex = -1;
    }

    function launchSelected() {
        const idx = launcher.isGrid ? gridView.currentIndex : listView.currentIndex;
        if (idx < 0 || idx >= filtered.length)
            return;

        const app = filtered[idx];
        const execArgs = app.runInTerminal ? [Config.launcher.terminal.exec, Config.launcher.terminal.execFlag, ...app.command] : app.command;

        Quickshell.execDetached({
            command: execArgs,
            workingDirectory: app.workingDirectory
        });

        LauncherState.close();
    }

    Timer {
        id: hideTimer
        interval: launcher.animationDuration + 20
        repeat: false
        onTriggered: LauncherState.switchTab('apps')
    }
}
