pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components

PanelWindow {
    id: notifications

    color: 'transparent'
    visible: NotificationsState.visible || container.x !== container._hiddenX
    exclusionMode: ExclusionMode.Normal

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: Config.shellName + '-notifications'

    readonly property var _position: {
        const position = Config.notifications.position;

        return {
            isTop: position.startsWith('top-'),
            isBottom: position.startsWith('bottom-'),
            isLeft: position.endsWith('-left'),
            isRight: position.endsWith('-right')
        };
    }

    readonly property int _cornerSide: {
        if (_position.isTop)
            return _position.isLeft ? Corner.Side.TopLeft : Corner.Side.TopRight;
        return _position.isLeft ? Corner.Side.BottomLeft : Corner.Side.BottomRight;
    }

    readonly property int _width: Config.notifications.width
    readonly property int _margins: Config.notifications.margin

    anchors.top: notifications._position.isTop
    anchors.bottom: notifications._position.isBottom
    anchors.left: notifications._position.isLeft
    anchors.right: notifications._position.isRight

    implicitWidth: notifications._width + cornerLeft.size
    implicitHeight: panel.height + cornerRight.size

    mask: Region {
        x: panel.x
        y: panel.y
        width: panel.width
        height: panel.height
    }

    Item {
        id: container

        property bool _settled: false
        readonly property int _hiddenX: (notifications._position.isLeft ? -1 : 1) * notifications.implicitWidth

        Component.onCompleted: Qt.callLater(() => container._settled = true)

        width: parent.width
        height: parent.height

        x: NotificationsState.visible ? 0 : container._hiddenX
        Behavior on x {
            enabled: container._settled
            NumberAnimation {
                duration: 300
                easing.type: NotificationsState.visible ? Easing.InCubic : Easing.InCubic
            }
        }

        Corner {
            id: cornerLeft
            color: Colorscheme.current.surface
            anchors.left: parent.left

            y: {
                if (notifications._position.isTop != notifications._position.isRight)
                    return parent.height - cornerLeft.size;
                return 0;
            }

            side: notifications._cornerSide
        }

        Rectangle {
            id: panel
            color: Colorscheme.current.surface

            width: notifications._width
            height: notifList.implicitHeight + notifications._margins * 2

            x: notifications._position.isRight ? cornerLeft.size : 0
            y: notifications._position.isBottom ? cornerRight.size : 0

            topLeftRadius: {
                if (notifications._position.isRight && !notifications._position.isTop)
                    return Config.general.radius;
            }

            topRightRadius: {
                if (notifications._position.isLeft && !notifications._position.isTop)
                    return Config.general.radius;
            }

            bottomLeftRadius: {
                if (notifications._position.isRight && notifications._position.isTop)
                    return Config.general.radius;
            }

            bottomRightRadius: {
                if (notifications._position.isLeft && notifications._position.isTop)
                    return Config.general.radius;
            }

            Column {
                id: notifList
                spacing: Config.notifications.gap
                anchors.fill: parent
                anchors.margins: notifications._margins

                Repeater {
                    model: NotificationsState.visibleNotifs
                    delegate: NotificationCard {}
                }
            }
        }

        Corner {
            id: cornerRight
            color: Colorscheme.current.surface
            anchors.right: parent.right

            y: {
                if (notifications._position.isTop == notifications._position.isRight)
                    return parent.height - cornerLeft.size;
                return 0;
            }

            side: notifications._cornerSide
        }
    }
}
