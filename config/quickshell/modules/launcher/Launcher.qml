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
        screen: modelData

        color: "transparent"
        anchors.left: true
        implicitWidth: 320
        implicitHeight: Math.round(launcher.screen.height * Config.launcher.heightFraction)
        exclusionMode: ExclusionMode.Ignore
        visible: shouldShow || hideTimer.running

        WlrLayershell.keyboardFocus: LauncherState.isOpen(launcher.modelData.name)
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        property bool shouldShow: LauncherState.isOpen(launcher.modelData.name)
        property list<DesktopEntry> filtered: entries

        readonly property bool isGrid: Config.launcher.viewMode === "grid"
        readonly property list<DesktopEntry> entries: DesktopEntries.applications.values

        readonly property int animationDuration: 600

        onShouldShowChanged: if (!shouldShow) hideTimer.restart();

        Column {
            id: container

            x: LauncherState.isOpen(launcher.modelData.name) ? 0 : -launcher.implicitWidth
            Behavior on x {
                NumberAnimation { duration: launcher.animationDuration; easing.type: Easing.OutCubic }
            }

            Corner {
                id: cornerTop
                side: Corner.Side.BottomLeft
                color: Colorscheme.current.surface
            }

            Rectangle {
                id: panel
                width: launcher.implicitWidth
                height: launcher.implicitHeight - cornerTop.size - cornerBottom.size
                topRightRadius: 10
                bottomRightRadius: 10
                color: Colorscheme.current.surface

                ColumnLayout {
                    spacing: 8
                    anchors.fill: parent
                    anchors.margins: 20

                    RowLayout {
                        spacing: 8
                        Layout.fillWidth: true

                        SearchBar {
                            id: searchBar
                            Layout.fillWidth: true

                            onTextChanged: launcher.filter()
                            onClose:       LauncherState.close()
                            onConfirm:     launcher.launchSelected()
                            onMoveUp:      launcher.isGrid ? gridView.moveCurrentIndexUp()   : listView.decrementCurrentIndex()
                            onMoveDown:    launcher.isGrid ? gridView.moveCurrentIndexDown() : listView.incrementCurrentIndex()
                            onMoveLeft:    if (launcher.isGrid) gridView.moveCurrentIndexLeft()
                            onMoveRight:   if (launcher.isGrid) gridView.moveCurrentIndexRight()
                        }

                        Rectangle {
                            width: 36
                            height: 36
                            radius: 8
                            color: viewToggle.containsMouse
                                ? Colorscheme.current.surface_variant
                                : Colorscheme.current.surface_container_high

                            Behavior on color { ColorAnimation { duration: 100 } }

                            Text {
                                anchors.centerIn: parent
                                font.family: "Material Symbols Rounded Filled"
                                font.pixelSize: 18
                                color: Colorscheme.current.on_surface
                                text: launcher.isGrid ? "list" : "grid_view"
                            }

                            MouseArea {
                                id: viewToggle
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Config.launcher.viewMode = launcher.isGrid ? "list" : "grid"
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

            Corner {
                id: cornerBottom
                side: Corner.Side.TopLeft
                color: Colorscheme.current.surface
            }
        }

        function filter() {
            const q = searchBar.text.toLowerCase().trim();
            filtered = entries.filter(a =>
                q === "" || a.name.toLowerCase().includes(q)
            );

            listView.currentIndex = -1;
            gridView.currentIndex = -1;
        }

        function launchSelected() {
            const idx = launcher.isGrid ? gridView.currentIndex : listView.currentIndex;
            if (idx < 0 || idx >= filtered.length)
                return;

            const app = filtered[idx];
            const execArgs = app.runInTerminal
                ? [Config.launcher.terminal.exec, Config.launcher.terminal.execFlag, ...app.command]
                : app.command;

            Quickshell.execDetached({
                command: execArgs,
                workingDirectory: app.workingDirectory,
            });
            LauncherState.close();
        }

        Connections {
            target: LauncherState

            function onOpenChanged() { _maybeActivate(); }
            function onActiveScreenChanged() { _maybeActivate(); }

            function _maybeActivate() {
                if (!LauncherState.open || LauncherState.activeScreen !== launcher.modelData.name)
                    return;

                searchBar.clear();
                launcher.filter();
                focusTimer.restart();
            }
        }

        Timer { id: hideTimer;   interval: animationDuration + 20; repeat: false }
        Timer { id: focusTimer;  interval: 30;  repeat: false; onTriggered: searchBar.activate() }
    }
}
