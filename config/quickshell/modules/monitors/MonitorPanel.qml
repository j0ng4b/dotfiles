pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.config
import qs.components
import qs.services

Rectangle {
    id: root

    radius: Config.general.radius
    color: Colorscheme.current.surface

    readonly property var selectedOutput: NiriService.outputs.find(output => output.name === MonitorState.selectedOutput) ?? null

    function _logicalSize(settings, output) {
        const portraitTransforms = ['90', '270', 'flipped-90', 'flipped-270'];
        const currentIsPortrait = portraitTransforms.includes(output.transform);
        const settingsIsPortrait = settings
            ? portraitTransforms.includes(settings.transform)
            : currentIsPortrait;

        const swap = settingsIsPortrait !== currentIsPortrait;
        return {
            width:  swap ? output.height : output.width,
            height: swap ? output.width  : output.height
        };
    }

    function _bbox(output) {
        const settings = MonitorState.getSettings(output.name);
        const size = root._logicalSize(settings, output);
        const left = settings ? settings.x : output.x;
        const top = settings ? settings.y : output.y;
        return {
            top: top,
            left: left,
            right: left + size.width,
            bottom: top + size.height
        };
    }

    function _computeRelations() {
        const active = NiriService.outputs.filter(output => !output.disabled);
        const relations = [];

        for (let i = 0; i < active.length; i++) {
            for (let j = i + 1; j < active.length; j++) {
                const a = _bbox(active[i]);
                const b = _bbox(active[j]);
                const gapX = Math.max(a.left, b.left) - Math.min(a.right, b.right);
                const gapY = Math.max(a.top, b.top) - Math.min(a.bottom, b.bottom);
                if (gapX !== 0 || gapY !== 0)
                    relations.push({
                        nameA: active[i].name,
                        nameB: active[j].name,
                        gapX,
                        gapY
                    });
            }
        }

        return relations;
    }

    function _outputStatus(name) {
        const relations = root._computeRelations();
        if (relations.length == 0)
            return 'ok';

        let hasGap = false, hasOverlap = false;

        for (const relation of relations) {
            if (relation.nameA !== name && relation.nameB !== name)
                continue;

            if (relation.gapX < 0 && relation.gapY < 0)
                hasOverlap = true;

            if (relation.gapX > 0 || relation.gapY > 0)
                hasGap = true;
        }

        if (hasOverlap)
            return 'overlap';

        if (hasGap)
            return 'gap';

        return 'ok';
    }

    focus: true

    Keys.onPressed: event => {
        const arrows = [Qt.Key_Left, Qt.Key_Right, Qt.Key_Up, Qt.Key_Down];
        if (!arrows.includes(event.key))
            return;

        const dx = event.key === Qt.Key_Left ? -1 : event.key === Qt.Key_Right ? 1 : 0;
        const dy = event.key === Qt.Key_Up ? -1 : event.key === Qt.Key_Down ? 1 : 0;

        MonitorState.nudgeSelected(dx, dy);
        event.accepted = true;
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        // banner dirty outputs
        Rectangle {
            Layout.fillWidth: true
            height: 36
            radius: Config.general.radius
            visible: MonitorState.hasDirtyOutputs()
            color: Colorscheme.current.tertiary_container

            RowLayout {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 15
                spacing: 8

                Icon {
                    icon: 'edit_note'
                    fill: true
                    color: Colorscheme.current.on_tertiary_container
                }

                Text {
                    visible: NiriService.applyError == ''
                    Layout.fillWidth: true
                    text: 'Unsaved changes.'
                    font.pixelSize: 14
                    color: Colorscheme.current.on_tertiary_container
                    elide: Text.ElideRight
                }

                Text {
                    visible: NiriService.applyError !== ''
                    Layout.fillWidth: true
                    text: NiriService.applyError
                    font.pixelSize: 14
                    color: Colorscheme.current.error
                    elide: Text.ElideRight
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            // left side
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8

                MonitorPanelHeader {}

                MonitorPanelCanvas {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    selectedOutput: root.selectedOutput
                    outputStatus: root._outputStatus
                    logicalSize: root._logicalSize
                }

                // legenda
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    RowLayout {
                        spacing: 4
                        Rectangle {
                            width: 9
                            height: 9
                            radius: 4.5
                            color: Colorscheme.current.tertiary
                        }

                        Text {
                            text: 'Gap'
                            font.pixelSize: 10
                            color: Colorscheme.current.on_surface_variant
                        }
                    }

                    RowLayout {
                        spacing: 4
                        Rectangle {
                            width: 9
                            height: 9
                            radius: 4.5
                            color: Colorscheme.current.error
                        }

                        Text {
                            text: 'Overlap'
                            font.pixelSize: 10
                            color: Colorscheme.current.on_surface_variant
                        }
                    }

                    // spacer
                    Item { Layout.fillWidth: true }

                    RowLayout {
                        visible: MonitorState.selectedOutput !== ''
                        spacing: 4

                        Icon {
                            icon: 'keyboard'
                            size: 14
                            color: Colorscheme.current.on_surface_variant
                            opacity: 0.5
                        }

                        Text {
                            text: `← ↑ → ↓  fine-tune (${MonitorState.snap} px)`
                            font.pixelSize: 10
                            color: Colorscheme.current.on_surface_variant
                            opacity: 0.5
                        }
                    }
                }
            }

            // right side
            MonitorPanelSidebar {
                Layout.preferredWidth: 300
                Layout.fillHeight: true

                selectedOutput: root.selectedOutput
                outputStatus: root._outputStatus
            }
        }
    }
}
