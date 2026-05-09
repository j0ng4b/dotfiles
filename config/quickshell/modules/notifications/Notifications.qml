pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.config
import qs.services
import qs.components

PanelWindow {
    id: notifications

    color: 'transparent'
    visible: NotificationsState.visible || container.x < notifications.implicitWidth
    exclusionMode: ExclusionMode.Normal
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: Config.shellName + '-notifications'

    readonly property string _position: Config.notifications.position
    readonly property bool _isTop: _position.startsWith('top')
    readonly property bool _isBottom: _position.startsWith('bottom')
    readonly property bool _isLeft: _position.endsWith('left')
    readonly property bool _isRight: _position.endsWith('right')

    readonly property int _width: Config.notifications.width
    readonly property int _margins: Config.notifications.margin

    anchors.top: notifications._isTop
    anchors.bottom: notifications._isBottom
    anchors.left: notifications._isLeft
    anchors.right: notifications._isRight

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

        width: parent.width
        height: parent.height

        x: NotificationsState.visible ? 0 : (notifications._isLeft ? -1 : 1) * notifications.implicitWidth
        Behavior on x {
            NumberAnimation {
                duration: 300
                easing.type: NotificationsState.visible ? Easing.InCubic : Easing.InCubic
            }
        }

        Corner {
            id: cornerLeft
            color: Colorscheme.current.surface

            anchors.left: parent.left
            anchors.bottom: {
                if (notifications._isTop)
                    return notifications._isRight ? undefined : parent.bottom;
                return notifications._isRight ? parent.bottom : undefined;
            }

            side: {
                if (notifications._isTop && notifications._isLeft)
                    return Corner.Side.TopLeft;
                if (notifications._isTop && notifications._isRight)
                    return Corner.Side.TopRight;
                if (notifications._isBottom && notifications._isLeft)
                    return Corner.Side.BottomLeft;
                if (notifications._isBottom && notifications._isRight)
                    return Corner.Side.BottomRight;
            }
        }

        Rectangle {
            id: panel
            color: Colorscheme.current.surface

            width: notifications._width
            height: notifList.implicitHeight + notifications._margins * 2

            x: notifications._isRight ? cornerLeft.size : 0
            y: notifications._isBottom ? cornerRight.size : 0

            topLeftRadius: notifications._isRight && !notifications._isTop ? Config.general.radius : undefined
            topRightRadius: notifications._isLeft && !notifications._isTop ? Config.general.radius : undefined
            bottomLeftRadius: notifications._isRight && notifications._isTop ? Config.general.radius : undefined
            bottomRightRadius: notifications._isLeft && notifications._isTop ? Config.general.radius : undefined

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
            anchors.bottom: {
                if (notifications._isTop)
                    return notifications._isRight ? parent.bottom : undefined;
                return notifications._isRight ? undefined : parent.bottom;
            }

            side: {
                if (notifications._isTop && notifications._isLeft)
                    return Corner.Side.TopLeft;
                if (notifications._isTop && notifications._isRight)
                    return Corner.Side.TopRight;
                if (notifications._isBottom && notifications._isLeft)
                    return Corner.Side.BottomLeft;
                if (notifications._isBottom && notifications._isRight)
                    return Corner.Side.BottomRight;
            }
        }
    }
}
