pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.config
import qs.components
import qs.services

RowLayout {
    Layout.fillWidth: true
    spacing: 8

    Icon {
        icon: 'desktop_windows'
        size: 18
        color: Colorscheme.current.primary
    }

    Text {
        text: 'Monitor Layout'
        font.pixelSize: 16
        font.bold: true
        color: Colorscheme.current.on_surface
    }

    Item {
        Layout.fillWidth: true
    }

    HeaderButton {
        visible: MonitorState.hasDirtyOutputs()
        icon: CompositorService.applying ? 'hourglass_empty' : 'check'
        label: CompositorService.applying ? 'Applying…' : 'Apply'
        activeColor: Colorscheme.current.primary
        activeOnColor: Colorscheme.current.on_primary
        idleColor: Colorscheme.current.primary_container
        idleOnColor: Colorscheme.current.on_primary_container
        enabled: !CompositorService.applying
        onClicked: MonitorState.applyAll()
    }

    HeaderButton {
        visible: MonitorState.hasDirtyOutputs()
        icon: 'undo'
        label: 'Reset'
        activeColor: Colorscheme.current.error_container
        activeOnColor: Colorscheme.current.on_error_container
        onClicked: MonitorState.resetAllSettings()
    }

    HeaderButton {
        icon: 'refresh'
        onClicked: CompositorService.refreshOutputs()
    }

    HeaderButton {
        icon: 'close'
        activeColor: Colorscheme.current.error_container
        activeOnColor: Colorscheme.current.on_error_container
        onClicked: MonitorState.close()
    }

    component HeaderButton: Rectangle {
        id: btn

        signal clicked

        property string icon: ''
        property string label: ''

        property color activeColor: Colorscheme.current.surface_container_high
        property color activeOnColor: Colorscheme.current.on_surface

        property color idleColor: 'transparent'
        property color idleOnColor: Colorscheme.current.on_surface

        readonly property bool hasLabel: label !== ''
        readonly property bool hovered: ma.containsMouse

        Layout.preferredWidth: hasLabel ? labelRow.implicitWidth + 24 : 32
        Layout.preferredHeight: 32
        radius: Config.general.radius

        color: hovered ? activeColor : idleColor
        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }

        RowLayout {
            id: labelRow
            anchors.centerIn: parent
            spacing: 4

            Icon {
                icon: btn.icon
                fill: btn.hovered && btn.hasLabel

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }
                color: btn.hovered ? btn.activeOnColor : btn.idleOnColor
            }

            Text {
                visible: btn.hasLabel
                text: btn.label
                font.pixelSize: 12
                font.bold: btn.hasLabel

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }
                color: btn.hovered ? btn.activeOnColor : btn.idleOnColor
            }
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: if (btn.enabled)
                btn.clicked()
        }
    }
}
