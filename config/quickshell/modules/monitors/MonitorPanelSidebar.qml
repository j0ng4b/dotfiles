pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.config
import qs.components
import qs.services

Rectangle {
    id: root

    required property var selectedOutput
    required property var outputStatus

    readonly property var selectedSettings: MonitorState.getSettings(MonitorState.selectedOutput)

    radius: Config.general.radius
    color: Colorscheme.current.surface_container_low

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // outputs list
        Text {
            text: 'Outputs'
            font.pixelSize: 14
            font.bold: true
            color: Colorscheme.current.on_surface
        }

        Flickable {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, 200)
            contentWidth: width
            contentHeight: cards.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            Column {
                id: cards
                width: parent.width
                spacing: 5

                Repeater {
                    model: NiriService.outputs

                    delegate: Rectangle {
                        id: outputCard
                        required property var modelData

                        readonly property bool isSelected: MonitorState.selectedOutput === modelData.name
                        readonly property bool isDirty: MonitorState.isDirty(modelData.name)
                        readonly property string status: root.outputStatus(modelData.name)

                        width: cards.width
                        height: 62
                        radius: Config.general.radius
                        border.width: (isSelected || status !== 'ok') ? 2 : 0

                        Behavior on color { ColorAnimation { duration: 250 } }
                        color: {
                            if (isSelected)
                                return Colorscheme.current.primary_container;

                            if (ocMa.containsMouse)
                                return Colorscheme.current.surface_container_high;

                            return Colorscheme.current.surface_container;
                        }

                        Behavior on border.color { ColorAnimation { duration: 250 } }
                        border.color: {
                            if (status === 'overlap')
                                return Colorscheme.current.error;

                            if (status === 'gap')
                                return Colorscheme.current.tertiary;

                            return isSelected ? Colorscheme.current.primary : 'transparent';
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 2

                            RowLayout {
                                spacing: 6

                                // dirty status
                                Rectangle {
                                    width: 8
                                    height: 8
                                    radius: 4
                                    visible: outputCard.isDirty
                                    color: {
                                        if (outputCard.status === 'overlap')
                                            return Colorscheme.current.error;

                                        if (outputCard.status === 'gap')
                                            return Colorscheme.current.tertiary;

                                        return Colorscheme.current.tertiary;
                                    }
                                }

                                Icon {
                                    icon: outputCard.modelData.disabled
                                        ? 'desktop_access_disabled' : 'desktop_windows'
                                    fill: outputCard.isSelected
                                    color: {
                                        if (outputCard.modelData.disabled)
                                            return Colorscheme.current.on_surface_variant;

                                        if (outputCard.isSelected)
                                            return Colorscheme.current.primary;

                                        return Colorscheme.current.secondary;
                                    }
                                }

                                // output name
                                Text {
                                    text: outputCard.modelData.name
                                    font.pixelSize: 12; font.bold: true
                                    color: {
                                        if (outputCard.isSelected)
                                            return Colorscheme.current.on_primary_container;
                                        return Colorscheme.current.on_surface;
                                    }
                                }

                                // output status
                                Text {
                                    font.pixelSize: 10
                                    opacity: 0.9

                                    text: {
                                        if (outputCard.status !== 'ok')
                                            return outputCard.status

                                        if (outputCard.modelData.focused)
                                            return 'focused';

                                        if (outputCard.modelData.disabled)
                                            return 'disabled';

                                        return 'active';
                                    }

                                    color: {
                                        if (outputCard.status === 'overlap')
                                            return Colorscheme.current.error;

                                        if (outputCard.status === 'gap')
                                            return Colorscheme.current.tertiary;

                                        if (outputCard.modelData.focused)
                                            return Colorscheme.current.primary;

                                        return Colorscheme.current.on_surface_variant;
                                    }
                                }
                            }

                            // output vendor
                            Text {
                                Layout.fillWidth: true
                                text: outputCard.modelData.make || 'Unknown display'
                                font.pixelSize: 10
                                elide: Text.ElideRight
                                opacity: 0.8
                                color: {
                                    if (outputCard.isSelected)
                                        return Colorscheme.current.on_primary_container;
                                    return Colorscheme.current.on_surface_variant;
                                }
                            }
                        }

                        MouseArea {
                            id: ocMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: MonitorState.selectOutput(outputCard.modelData.name)
                        }
                    }
                }
            }
        }

        Separator { Layout.fillWidth: true }

        // output editor
        Text {
            text: root.selectedOutput ? 'Edit — ' + root.selectedOutput.name : 'Select an output'
            font.pixelSize: 12
            font.bold: true
            color: Colorscheme.current.on_surface
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            visible: root.selectedOutput !== null

            // modes
            ColumnLayout {
                spacing: 4
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(
                    modeList.contentHeight + 4,
                    150
                )

                SectionLabel { title: 'Mode' }

                ListView {
                    id: modeList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 2
                    boundsBehavior: Flickable.StopAtBounds
                    model: root.selectedOutput ? root.selectedOutput.modes : []

                    delegate: SelectableChip {
                        required property var modelData

                        flat: true
                        width: modeList.width
                        label: modelData.label
                        isSelected: root.selectedSettings?.mode === modelData.label
                        leadIcon:  modelData.isPreferred ? 'star' : ''
                        trailIcon: 'check'
                        trailVisible: isSelected

                        onClicked: {
                            MonitorState.patchSettings(
                                MonitorState.selectedOutput, { mode: modelData.label }
                            )
                        }
                    }
                }
            }

            Separator { Layout.fillWidth: true }

            // scale
            EditorSection {
                title: 'Scale'

                Row {
                    width: parent.width; spacing: 4
                    Repeater {
                        model: [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
                        delegate: SelectableChip {
                            required property var modelData

                            width: (parent.width - 24) / 7
                            label: modelData % 1 === 0 ? modelData.toFixed(0) : modelData.toFixed(2)
                            labelAlign: Text.AlignHCenter
                            isSelected: root.selectedSettings !== null &&
                                        Math.abs(root.selectedSettings.scale - modelData) < 0.01

                            onClicked: {
                                MonitorState.patchSettings(
                                    MonitorState.selectedOutput, { scale: modelData }
                                )
                            }
                        }
                    }
                }
            }

            // transform
            EditorSection {
                title: 'Transform'

                Grid {
                    width: parent.width
                    columns: 4
                    rowSpacing: 4
                    columnSpacing: 4

                    Repeater {
                        model: ['normal', '90', '180', '270',
                                'flipped', 'flipped-90', 'flipped-180', 'flipped-270']
                        delegate: SelectableChip {
                            required property string modelData

                            width: (parent.width - 12) / 4
                            label: modelData
                            labelAlign: Text.AlignHCenter
                            isSelected: root.selectedSettings?.transform === modelData

                            onClicked: {
                                MonitorState.patchSettings(
                                    MonitorState.selectedOutput, { transform: modelData }
                                )
                            }
                        }
                    }
                }
            }

            // position
            EditorSection {
                title: 'Position'
                Row {
                    width: parent.width;
                    spacing: 6

                    PositionField {
                        axis: 'x'
                        width: (parent.width - 6) / 2
                        height: 30
                        settings: root.selectedSettings
                    }

                    PositionField {
                        axis: 'y'
                        width: (parent.width - 6) / 2
                        height: 30
                        settings: root.selectedSettings
                    }
                }
            }

            // spacer push buttons to bottom
            Item { Layout.fillHeight: true }

            Separator {
                Layout.fillWidth: true
                visible: MonitorState.isDirty(MonitorState.selectedOutput)
                    || (root.selectedOutput !== null && !root.selectedOutput.focused)
            }

            // reset output
            ActionButton {
                text: 'Reset this output'
                icon: 'undo'
                visible: MonitorState.isDirty(MonitorState.selectedOutput)
                isPrimary: false
                onClicked: MonitorState.resetSettings(MonitorState.selectedOutput)
            }

            // focus output
            ActionButton {
                text: 'Focus this output'
                icon: 'center_focus_strong'
                visible: root.selectedOutput !== null && !root.selectedOutput.focused
                isPrimary: true

                onClicked: {
                    if (root.selectedOutput)
                        NiriService.focusOutput(root.selectedOutput.name);
                }
            }
        }

        // placeholder
        Item {
            Layout.fillHeight: true;
            visible: root.selectedOutput === null
        }
    }

    component Separator: Rectangle {
        height: 2
        opacity: 0.2
        color: Colorscheme.current.outline
    }

    component SelectableChip: Rectangle {
        id: chip

        property int labelAlign: Text.AlignLeft
        property string label: ''
        property string leadIcon: ''
        property string trailIcon: ''
        property bool trailVisible: false
        property bool isSelected: false
        property bool flat: false

        signal clicked()

        height: 28
        radius: 4

        Behavior on color { ColorAnimation { duration: 200 } }
        color: {
            if (isSelected)
                return Colorscheme.current.primary_container;

            if (chipMa.containsMouse)
                return Colorscheme.current.surface_container_high;

            if (flat)
                return 'transparent';
            return Colorscheme.current.surface_container;
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 6

            Icon {
                visible: chip.leadIcon !== ''
                icon: chip.leadIcon
                size: 13
                color: chip.isSelected
                    ? Colorscheme.current.on_primary_container
                    : Colorscheme.current.on_surface
            }

            Text {
                Layout.fillWidth: true
                text: chip.label
                horizontalAlignment: chip.labelAlign
                font.pixelSize: 10
                color: chip.isSelected
                    ? Colorscheme.current.on_primary_container
                    : Colorscheme.current.on_surface
            }

            Icon {
                visible: chip.trailVisible && chip.trailIcon !== ''
                icon: chip.trailIcon
                size: 13
                fill: chip.isSelected
                color: chip.isSelected
                    ? Colorscheme.current.on_primary_container
                    : Colorscheme.current.on_surface_variant
            }
        }

        MouseArea {
            id: chipMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: chip.clicked()
        }
    }

    component SectionLabel: Text {
        property string title: 'test'

        text: title.toUpperCase()
        antialiasing: true
        font.bold: true
        font.pixelSize: 10
        color: Colorscheme.current.on_surface_variant
        opacity: 0.5
    }

    component EditorSection: ColumnLayout {
        id: section

        property string title: ''
        default property alias content: contentSlot.data

        Layout.fillWidth: true
        spacing: 4

        SectionLabel { title: section.title }

        Item {
            id: contentSlot
            Layout.fillWidth: true
            implicitHeight: childrenRect.height
        }
    }

    component PositionField: Rectangle {
        id: posRect

        property string axis: 'x'
        property var settings: null

        radius: 4
        color: Colorscheme.current.surface_container

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 4

            Text {
                text: posRect.axis.toUpperCase() + ':'
                font.pixelSize: 10
                font.bold: true
                color: Colorscheme.current.on_surface_variant
            }

            TextInput {
                Layout.fillWidth: true
                font.pixelSize: 11
                color: Colorscheme.current.on_surface
                text: posRect.settings
                    ? String(posRect.axis === 'x' ? posRect.settings.x : posRect.settings.y)
                    : '0'
                validator: IntValidator { bottom: -20000; top: 20000 }
                onEditingFinished: {
                    const val = parseInt(text) || 0;
                    const patch = {};
                    patch[posRect.axis] = val;
                    MonitorState.patchSettings(MonitorState.selectedOutput, patch);
                }
            }
        }
    }

    component ActionButton: Rectangle {
        id: btnRoot

        signal clicked()

        property string text: ''
        property string icon: ''
        property bool isPrimary: false

        Layout.fillWidth: true
        height: 30
        radius: Config.general.radius

        Behavior on color { ColorAnimation { duration: 200 } }
        color: {
            if (btnMa.containsMouse) {
                if (isPrimary)
                    return Colorscheme.current.primary_container;
                else
                    return Colorscheme.current.surface_container_high;
            }

            return Colorscheme.current.surface_container;
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: 6

            Icon {
                icon: btnRoot.icon
                fill: btnMa.containsMouse

                Behavior on color { ColorAnimation { duration: 200 } }
                color: {
                    if (btnRoot.isPrimary && btnMa.containsMouse)
                        return Colorscheme.current.on_primary_container;
                    return Colorscheme.current.on_surface;
                }
            }

            Text {
                text: btnRoot.text
                font.pixelSize: 12

                Behavior on color { ColorAnimation { duration: 200 } }
                color: {
                    if (btnRoot.isPrimary && btnMa.containsMouse)
                        return Colorscheme.current.on_primary_container;
                    return Colorscheme.current.on_surface;
                }
            }
        }

        MouseArea {
            id: btnMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btnRoot.clicked()
        }
    }
}
