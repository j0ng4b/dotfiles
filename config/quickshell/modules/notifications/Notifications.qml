pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.config
import qs.components

Item {
    id: notifications

    required property var screen

    readonly property bool active: NotificationsState.isActiveOn(notifications.screen.name)

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

    readonly property var mask: Region {
        x: container.x + panel.x
        y: container.y + panel.y
        width: panel.width
        height: panel.height
    }

    enabled: notifications.active
    anchors.fill: parent

    Item {
        id: container

        readonly property int _shownX: notifications._position.isLeft ? 0 : parent.width - container.width
        readonly property int _hiddenX: notifications._position.isLeft ? -container.width : parent.width

        width: notifications._width + cornerLeft.size
        height: panel.height + cornerRight.size

        anchors.top: notifications._position.isTop ? parent.top : undefined
        anchors.bottom: notifications._position.isBottom ? parent.bottom : undefined
        anchors.topMargin: notifications._position.isTop ? Config.general.barHeight : 0

        x: notifications.active ? container._shownX : container._hiddenX
        Behavior on x {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InCubic
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
                    model: notifications.active ? NotificationsState.visibleNotifs : null
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
