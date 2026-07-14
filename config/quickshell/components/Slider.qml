import QtQuick
import QtQuick.Layouts
import qs.config

Item {
    id: root

    required property string icon
    property real value: 0.0
    property color activeColor: Colorscheme.current.primary

    signal moved(real value)
    signal iconClicked

    property bool _awaitingValueUpdate: false
    readonly property real _display: dragArea.pressed || root._awaitingValueUpdate ? root._dragValue : root.value
    property real _dragValue: root.value

    implicitHeight: 32

    onValueChanged: {
        if (root._awaitingValueUpdate && Math.abs(root.value - root._dragValue) < 0.001)
            root._awaitingValueUpdate = false;
    }

    function _ratioFromX(x) {
        return Math.max(0, Math.min(1, x / track.width));
    }

    RowLayout {
        anchors.fill: parent
        spacing: 10

        Rectangle {
            id: iconWrap
            Layout.preferredWidth: 26
            Layout.preferredHeight: 26
            radius: 6

            color: iconMa.containsMouse ? Colorscheme.current.surface_container_high : 'transparent'
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            Icon {
                icon: root.icon
                fill: true
                size: 18
                anchors.centerIn: parent
                color: Colorscheme.current.on_surface
            }

            MouseArea {
                id: iconMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.iconClicked()
            }
        }

        Rectangle {
            id: track
            Layout.fillWidth: true
            Layout.preferredHeight: 8
            radius: 4
            color: Colorscheme.current.surface_container_high

            Rectangle {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(height, track.width * root._display)
                height: parent.height
                radius: parent.radius
                color: root.activeColor
            }

            Rectangle {
                width: 14
                height: 14
                radius: 7
                color: root.activeColor
                border.color: Colorscheme.current.surface
                border.width: 2
                anchors.verticalCenter: parent.verticalCenter
                x: Math.min(track.width - width, Math.max(0, track.width * root._display - width / 2))
            }

            MouseArea {
                id: dragArea

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onPressed: mouse => {
                    root._dragValue = root._ratioFromX(mouse.x);
                    root._awaitingValueUpdate = true;
                    root.moved(root._dragValue);
                }

                onPositionChanged: mouse => {
                    if (!pressed)
                        return;

                    root._dragValue = root._ratioFromX(mouse.x);
                    root._awaitingValueUpdate = true;
                    root.moved(root._dragValue);
                }

                onReleased: {
                    if (Math.abs(root.value - root._dragValue) < 0.001)
                        root._awaitingValueUpdate = false;
                }

                onCanceled: {
                    root._awaitingValueUpdate = false;
                    root._dragValue = root.value;
                }
            }
        }
    }
}
