pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: launcher
        required property var modelData
        screen: modelData

        anchors.top: true
        anchors.left: true
        anchors.bottom: true

        implicitWidth: 280
        color: 'transparent'
        exclusionMode: ExclusionMode.Ignore

        readonly property bool shouldShow:
            LauncherState.open && LauncherState.activeScreen === launcher.modelData.name

        visible: shouldShow || hideTimer.running

        WlrLayershell.keyboardFocus: shouldShow
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        onShouldShowChanged: {
            if (!shouldShow)
                hideTimer.restart();
        }

        Timer {
            id: hideTimer
            interval: 310
            repeat: false
        }

        readonly property list<DesktopEntry> entries: DesktopEntries.applications.values
        property list<DesktopEntry> filtered: entries

        Rectangle {
            id: panel
            width: launcher.implicitWidth
            height: launcher.height
            color: Colorscheme.current.surface

            x: launcher.shouldShow ? 0 : -launcher.implicitWidth

            Behavior on x {
                NumberAnimation {
                    duration: 300
                    easing.type: launcher.shouldShow ? Easing.OutCubic : Easing.InCubic
                }
            }

            Rectangle {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: 1
                color: Colorscheme.current.surface_variant
                opacity: 0.5
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    radius: 8
                    color: Colorscheme.current.surface_container_high

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        verticalAlignment: Text.AlignVCenter
                        visible: searchInput.text === ''
                        text: 'Search apps...'
                        color: Colorscheme.current.on_surface
                        opacity: 0.4
                        font.pixelSize: 13
                    }

                    TextInput {
                        id: searchInput
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        color: Colorscheme.current.on_surface
                        font.pixelSize: 13
                        clip: true
                        onTextChanged: launcher.filter()

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                LauncherState.close();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Down) {
                                appList.incrementCurrentIndex();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Up) {
                                appList.decrementCurrentIndex();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                launcher.launchSelected();
                                event.accepted = true;
                            }
                        }
                    }
                }

                ListView {
                    id: appList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 2
                    model: launcher.filtered
                    highlightFollowsCurrentItem: true
                    keyNavigationEnabled: false
                    currentIndex: -1

                    highlight: Rectangle {
                        color: Colorscheme.current.surface_container_high
                        radius: 6
                    }

                    delegate: Rectangle {
                        id: entry
                        required property var modelData
                        required property int index
                        width: appList.width
                        height: 40
                        radius: 6
                        color: appList.currentIndex === index || ma.containsMouse
                            ? Colorscheme.current.surface_container_high
                            : 'transparent'

                        Behavior on color { ColorAnimation { duration: 100 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 10

                            Image {
                                id: appIcon
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                sourceSize: Qt.size(24, 24)
                                source: Quickshell.iconPath(entry.modelData.icon) || ''

                                Rectangle {
                                    anchors.fill: parent
                                    color: Colorscheme.current.primary
                                    radius: 4
                                    visible: appIcon.source === '' || appIcon.status === Image.Error

                                    Text {
                                        anchors.centerIn: parent
                                        text: entry.modelData.name.charAt(0).toUpperCase()
                                        color: Colorscheme.current.on_primary
                                        font.pixelSize: 12
                                        font.bold: true
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: entry.modelData.name
                                color: Colorscheme.current.on_surface
                                font.pixelSize: 13
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        MouseArea {
                            id: ma
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                appList.currentIndex = index;
                                launcher.launchSelected();
                            }
                            onEntered: appList.currentIndex = index
                        }
                    }
                }
            }
        }

        function filter() {
            appList.currentIndex = -1;
            const q = searchInput.text.toLowerCase().trim();
            filtered = entries.filter(a =>
                q === '' || a.name.toLowerCase().includes(q)
            );
        }

        function launchSelected() {
            if (appList.currentIndex < 0 || appList.currentIndex >= filtered.length)
                return;

            const app = filtered[appList.currentIndex];
            const execArgs = app.runInTerminal
                ? [Config.terminal.exec, Config.terminal.execFlag, ...app.command]
                : app.command;

            Quickshell.execDetached({
                command: execArgs,
                workingDirectory: app.workingDirectory,
            });

            LauncherState.close();
        }

        Connections {
            target: LauncherState

            function onOpenChanged()        { _maybeActivate(); }
            function onActiveScreenChanged() { _maybeActivate(); }

            function _maybeActivate() {
                if (!LauncherState.open || LauncherState.activeScreen !== launcher.modelData.name)
                    return;

                searchInput.text = '';
                launcher.filter();

                appList.currentIndex = -1;
                focusTimer.restart();
            }
        }

        Timer {
            id: focusTimer
            interval: 30
            repeat: false
            onTriggered: searchInput.forceActiveFocus()
        }
    }
}
