pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components
import qs.services
import qs.modules.launcher.components

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: launcher
        required property var modelData

        color: 'transparent'
        screen: modelData
        exclusionMode: ExclusionMode.Ignore

        anchors.left: true

        visible: shouldShow || hideTimer.running
        implicitWidth: 320
        implicitHeight: Math.round(launcher.screen.height * Config.launcher.heightFraction)

        WlrLayershell.keyboardFocus: {
            if (LauncherState.isOpen(launcher.modelData.name))
                return WlrKeyboardFocus.Exclusive;
            return WlrKeyboardFocus.None;
        }

        property bool shouldShow: LauncherState.isOpen(launcher.modelData.name)
        property list<DesktopEntry> filtered: entries

        readonly property bool isGrid: Config.launcher.viewMode === 'grid'
        readonly property int tabIndex: LauncherState.activeTab === 'wallpapers' ? 1 : 0
        readonly property int animationDuration: 400
        readonly property list<DesktopEntry> entries: DesktopEntries.applications.values

        onShouldShowChanged: if (!shouldShow)
            hideTimer.restart()

        Column {
            id: container

            x: LauncherState.isOpen(launcher.modelData.name) ? 0 : -launcher.implicitWidth
            Behavior on x {
                NumberAnimation {
                    duration: launcher.animationDuration
                    easing.type: shouldShow ? Easing.OutCubic : Easing.InCubic
                }
            }

            Corner {
                id: cornerTop
                side: Corner.Side.BottomLeft
                color: Colorscheme.current.surface
            }

            Rectangle {
                id: panel
                color: Colorscheme.current.surface
                width: launcher.implicitWidth
                height: launcher.implicitHeight - cornerTop.size - cornerBottom.size
                topRightRadius: Config.general.radius
                bottomRightRadius: Config.general.radius

                ColumnLayout {
                    spacing: 8
                    anchors.fill: parent
                    anchors.margins: 20

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

                            x: launcher.tabIndex === 0 ? 3 : 3 + width + 3
                            y: 3

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

                            // Apps button
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

                            // Wallpapers button
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
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        Item {
                            id: contentStrip

                            property int singleWidth: parent.width

                            width: singleWidth * 2
                            height: parent.height

                            x: launcher.tabIndex === 0 ? 0 : -contentStrip.singleWidth
                            Behavior on x {
                                NumberAnimation {
                                    duration: 260
                                    easing.type: Easing.OutCubic

                                    onRunningChanged: {
                                        if (!running && contentStrip.x == -contentStrip.singleWidth)
                                            WallpaperService.rescan();
                                    }
                                }
                            }

                            Item {
                                x: 0
                                width: contentStrip.singleWidth
                                height: parent.height

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 8

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

                            Item {
                                x: contentStrip.singleWidth
                                width: contentStrip.singleWidth
                                height: parent.height

                                WallpaperSelector {
                                    id: wallpaperSelector
                                    anchors.fill: parent

                                    onWallpaperSelected: path => {
                                        Config.wallpaper.source = Qt.resolvedUrl(path);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Corner {
                id: cornerBottom
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

        Connections {
            target: LauncherState

            function onOpenChanged() {
                _maybeActivate();
            }
            function onActiveScreenChanged() {
                _maybeActivate();
            }

            function _maybeActivate() {
                if (!LauncherState.open || LauncherState.activeScreen !== launcher.modelData.name)
                    return;

                searchBar.clear();
                launcher.filter();
                focusTimer.restart();
            }
        }

        Timer {
            id: hideTimer
            interval: animationDuration + 20
            repeat: false
            onTriggered: LauncherState.switchTab('apps')
        }

        Timer {
            id: focusTimer
            interval: 30
            repeat: false
            onTriggered: searchBar.activate()
        }
    }
}
