import QtQuick
import qs.config

Rectangle {
    id: root

    signal close
    signal moveUp
    signal moveDown
    signal moveLeft
    signal moveRight
    signal confirm
    signal tab

    property alias text: input.text

    function clear() {
        input.text = '';
    }

    function activate() {
        input.forceActiveFocus();
    }

    height: 36
    radius: 8
    color: Colorscheme.current.surface_container_high

    Text {
        anchors.fill: parent
        anchors.leftMargin: 12
        verticalAlignment: Text.AlignVCenter
        visible: input.text === ''
        text: 'Search apps...'
        color: Colorscheme.current.on_surface
        opacity: 0.4
        font.pixelSize: 13
    }

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        verticalAlignment: TextInput.AlignVCenter
        color: Colorscheme.current.on_surface
        font.pixelSize: 13
        clip: true

        Keys.onPressed: event => {
            switch (event.key) {
            case Qt.Key_Escape:
                root.close();
                break;
            case Qt.Key_Up:
                root.moveUp();
                break;
            case Qt.Key_Down:
                root.moveDown();
                break;
            case Qt.Key_Left:
                root.moveLeft();
                break;
            case Qt.Key_Right:
                root.moveRight();
                break;
            case Qt.Key_Tab:
                root.tab();
                break;
            case Qt.Key_Return:
            case Qt.Key_Enter:
                root.confirm();
                break;
            default:
                return;
            }

            event.accepted = true;
        }
    }
}
