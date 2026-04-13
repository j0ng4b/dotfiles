pragma ComponentBehavior: Bound

import QtQuick

import qs.config
import qs.components
import qs.services

Rectangle {
    id: root
    radius: Config.general.radius
    color: Colorscheme.current.surface_container_low
    clip: true

    required property var selectedOutput
    required property var outputStatus
    required property var logicalSize

    // grid
    Item {
        anchors.fill: parent
        anchors.margins: 1
        clip: true

        Repeater {
            model: 20
            Rectangle {
                required property int index

                visible: index
                y: index * parent.height / 14
                width: parent.width
                height: 1
                color: Colorscheme.current.outline
                opacity: 0.1
            }
        }

        Repeater {
            model: 20
            Rectangle {
                required property int index

                visible: index
                x: index * parent.width / 14
                width: 1
                height: parent.height
                color: Colorscheme.current.outline
                opacity: 0.1
            }
        }
    }

    // placeholder
    Column {
        visible: CompositorService.outputs.filter(output => !output.disabled).length === 0
        anchors.centerIn: parent
        spacing: 8

        Icon {
            icon: 'desktop_access_disabled'
            size: 32
            anchors.horizontalCenter: parent.horizontalCenter
            color: Colorscheme.current.on_surface
            opacity: 0.3
        }

        Text {
            text: 'No active outputs'
            font.pixelSize: 14
            color: Colorscheme.current.on_surface
            opacity: 0.4
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Item {
        id: layoutArea
        anchors.fill: parent
        anchors.margins: 24

        readonly property var active: CompositorService.outputs.filter(output => !output.disabled)

        readonly property real minX: {
            if (active.length === 0)
                return 0;

            return active.reduce((m, output) => {
                const settings = MonitorState.getSettings(output.name);
                return Math.min(m, settings ? settings.x : output.x);
            }, Infinity);
        }

        readonly property real minY: {
            if (active.length === 0)
                return 0;

            return active.reduce((min, output) => {
                const settings = MonitorState.getSettings(output.name);
                return Math.min(min, settings ? settings.y : output.y);
            }, Infinity);
        }

        readonly property real maxX: {
            if (active.length === 0)
                return 1;

            return active.reduce((max, output) => {
                const settings = MonitorState.getSettings(output.name);
                const size = root.logicalSize(settings, output);
                return Math.max(max, (settings ? settings.x : output.x) + size.width);
            }, -Infinity);
        }

        readonly property real maxY: {
            if (active.length === 0)
                return 1;

            return active.reduce((max, output) => {
                const settings = MonitorState.getSettings(output.name);
                const size = root.logicalSize(settings, output);
                return Math.max(max, (settings ? settings.y : output.y) + size.height);
            }, -Infinity);
        }

        readonly property real logicalWidth: Math.max(1, maxX - minX)
        readonly property real logicalHeight: Math.max(1, maxY - minY)
        readonly property real scale: Math.min(width / logicalWidth, height / logicalHeight) * 0.80
        readonly property real offX: (width - logicalWidth * scale) / 2
        readonly property real offY: (height - logicalHeight * scale) / 2

        Repeater {
            model: layoutArea.active
            delegate: Item {
                id: tile
                required property var modelData

                readonly property var settings: MonitorState.getSettings(modelData.name)
                readonly property var logicalSize: root.logicalSize(settings, modelData)
                readonly property bool isSelected: MonitorState.selectedOutput === modelData.name
                readonly property bool isDirty: MonitorState.isDirty(modelData.name)
                readonly property string status: root.outputStatus(modelData.name)

                readonly property real settingsX: settings ? settings.x : modelData.x
                readonly property real settingsY: settings ? settings.y : modelData.y

                // logical drag position, converted from canvas to logical
                readonly property int dragLogicalX: Math.round((x - layoutArea.offX) / layoutArea.scale + layoutArea.minX)
                readonly property int dragLogicalY: Math.round((y - layoutArea.offY) / layoutArea.scale + layoutArea.minY)

                x: (settingsX - layoutArea.minX) * layoutArea.scale + layoutArea.offX
                y: (settingsY - layoutArea.minY) * layoutArea.scale + layoutArea.offY
                width: Math.max(80, logicalSize.width * layoutArea.scale)
                height: Math.max(56, logicalSize.height * layoutArea.scale)

                // output tile rectangle
                Rectangle {
                    anchors.fill: parent
                    radius: Config.general.radius

                    color: {
                        if (tile.isSelected)
                            return Colorscheme.current.primary_container;

                        if (tile.status === 'overlap')
                            return Qt.rgba(Colorscheme.current.error.r, Colorscheme.current.error.g, Colorscheme.current.error.b, 0.15);

                        if (tile.status === 'gap')
                            return Qt.rgba(Colorscheme.current.tertiary.r, Colorscheme.current.tertiary.g, Colorscheme.current.tertiary.b, 0.15);

                        return Colorscheme.current.surface_container_high;
                    }

                    border.width: (tile.status !== 'ok' || tile.isSelected) ? 2 : 1
                    border.color: {
                        if (tile.status === 'overlap')
                            return Colorscheme.current.error;

                        if (tile.status === 'gap')
                            return Colorscheme.current.tertiary;

                        if (tile.isSelected)
                            return tile.isDirty ? Colorscheme.current.tertiary : Colorscheme.current.primary;

                        return hh.hovered ? Colorscheme.current.secondary : Colorscheme.current.outline;
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 250
                        }
                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 250
                        }
                    }

                    // gap/overlap status
                    Icon {
                        visible: tile.status !== 'ok'
                        icon: tile.status === 'overlap' ? 'layers' : 'space_bar'
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.margins: 6
                        color: tile.status === 'overlap' ? Colorscheme.current.error : Colorscheme.current.tertiary
                        opacity: 0.85
                    }

                    // badge dirty
                    Rectangle {
                        visible: tile.isDirty
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: 6
                        width: 8
                        height: 8
                        radius: 4
                        color: Colorscheme.current.tertiary
                    }

                    Icon {
                        icon: 'drag_indicator'
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 4
                        opacity: tile.isSelected ? 0.5 : 0
                        color: Colorscheme.current.on_surface
                    }

                    // output settings
                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        // name
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: tile.modelData.name
                            font.pixelSize: Math.max(9, Math.min(13, tile.width / 9))
                            font.bold: true
                            color: tile.isSelected ? Colorscheme.current.on_primary_container : Colorscheme.current.on_surface
                        }

                        // mode
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: tile.settings ? tile.settings.mode : '—'
                            font.pixelSize: Math.max(8, Math.min(11, tile.width / 12))
                            color: tile.isSelected ? Colorscheme.current.on_primary_container : Colorscheme.current.on_surface_variant
                        }

                        // position
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.pixelSize: Math.max(7, Math.min(10, tile.width / 14))
                            font.bold: dragArea.drag.active
                            text: {
                                if (dragArea.drag.active)
                                    return tile.dragLogicalX + ', ' + tile.dragLogicalY;

                                if (tile.settings)
                                    return tile.settings.x + ', ' + tile.settings.y;

                                return tile.modelData.x + ', ' + tile.modelData.y;
                            }
                            color: {
                                if (dragArea.drag.active)
                                    return Colorscheme.current.primary;

                                if (tile.status === 'overlap')
                                    return Colorscheme.current.error;

                                if (tile.status === 'gap')
                                    return Colorscheme.current.tertiary;

                                return tile.isSelected ? Colorscheme.current.on_primary_container : Colorscheme.current.on_surface_variant;
                            }
                        }
                    }
                }

                // drag tooltip
                Rectangle {
                    id: dragTooltip
                    visible: dragArea.drag.active
                    x: (tile.width - width) / 2
                    y: tile.y > 30 ? -height - 6 : tile.height + 6
                    width: tooltipText.implicitWidth + 16
                    height: 24
                    radius: Config.general.radius
                    color: Colorscheme.current.inverse_surface
                    opacity: 0.92

                    Text {
                        id: tooltipText
                        anchors.centerIn: parent
                        text: 'x: ' + tile.dragLogicalX + '  y: ' + tile.dragLogicalY
                        font.pixelSize: 12
                        font.bold: true
                        color: Colorscheme.current.inverse_on_surface
                    }
                }

                HoverHandler {
                    id: hh
                }

                MouseArea {
                    id: dragArea
                    anchors.fill: parent
                    hoverEnabled: true
                    drag.target: tile
                    drag.axis: Drag.XAndYAxis
                    drag.smoothed: false
                    cursorShape: {
                        if (drag.active)
                            return Qt.ClosedHandCursor;
                        return tile.isSelected ? Qt.OpenHandCursor : Qt.PointingHandCursor;
                    }

                    onClicked: MonitorState.selectOutput(tile.modelData.name)
                    onReleased: {
                        if (!drag.active)
                            return;
                        MonitorState.dragOutput(tile.modelData.name, dragLogicalX, dragLogicalY);
                    }
                }
            }
        }
    }
}
