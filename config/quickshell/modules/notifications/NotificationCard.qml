pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs.config
import qs.components

Item {
    id: root

    required property int notifId
    required property string appName
    required property string iconSrc
    required property string summary
    required property string body
    required property string bodyImage
    required property int urgency
    required property int expireTimeout
    required property bool hasActionIcons
    required property var actions

    property bool _dismissing: false
    property bool _expanded: false

    property real _elapsed: 0
    property real _startedAt: 0

    readonly property bool _isCritical: root.urgency === 2

    readonly property int _effectiveTimeout: {
        if (!Config.notifications.ignoreAppExpireTimeout && root.expireTimeout >= -1)
            return root.expireTimeout;

        return Config.notifications.expireTimeout;
    }

    clip: true
    implicitWidth: parent.width
    implicitHeight: card.implicitHeight

    function startDismiss() {
        if (root._dismissing)
            return;

        root._dismissing = true;
        expireTimer.stop();
        dismissAnim.start();
    }

    function _startTimer() {
        if (root._effectiveTimeout <= 0 || root._dismissing)
            return;

        root._startedAt = Date.now();
        expireTimer.interval = Math.max(1, root._effectiveTimeout - root._elapsed);
        expireTimer.start();
    }

    function _pauseTimer() {
        if (!expireTimer.running)
            return;

        root._elapsed += Date.now() - root._startedAt;
        expireTimer.stop();
    }

    // Triggers the dismiss animation if the notification is closed externally
    Connections {
        target: NotificationsState
        function onNotificationClosed(notifId) {
            if (notifId === root.notifId)
                root.startDismiss();
        }
    }

    HoverHandler {
        target: card
        onHoveredChanged: {
            if (root._dismissing)
                return;

            if (hovered)
                root._pauseTimer();
            else
                root._startTimer();
        }
    }

    Timer {
        id: expireTimer
        running: false
        repeat: false
        onTriggered: root.startDismiss()
    }

    ParallelAnimation {
        id: entryAnim

        NumberAnimation {
            target: card
            property: 'opacity'
            from: 0
            to: 1
            duration: 180
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: cardTranslate
            property: 'x'
            from: Config.notifications.position.endsWith('left') ? -50 : 50
            to: 0
            duration: 260
            easing.type: Easing.OutCubic
        }
    }

    SequentialAnimation {
        id: dismissAnim

        ParallelAnimation {
            NumberAnimation {
                target: card
                property: 'opacity'
                to: 0
                duration: 200
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: cardTranslate
                property: 'x'
                from: 0
                to: Config.notifications.position.endsWith('left') ? -50 : 50
                duration: 260
                easing.type: Easing.OutCubic
            }
        }

        ScriptAction {
            script: NotificationsState.dismiss(root.notifId)
        }
    }

    Component.onCompleted: {
        entryAnim.start();
        root._startTimer();
    }

    Rectangle {
        id: card

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        implicitHeight: mainCol.implicitHeight + 20
        radius: Config.general.radius

        color: root._isCritical ? Colorscheme.current.error_container : Colorscheme.current.surface_container_high

        transform: Translate {
            id: cardTranslate
            x: 0
        }

        Rectangle {
            visible: root._isCritical
            width: 3
            color: Colorscheme.current.error
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                topMargin: parent.radius
                bottomMargin: parent.radius
            }
        }

        ColumnLayout {
            id: mainCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 12
                topMargin: 10
            }
            spacing: 5

            // Header: app icon + app name + dismiss
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Image {
                    visible: root.iconSrc !== ''
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                    source: root.iconSrc
                    fillMode: Image.PreserveAspectFit
                    sourceSize: Qt.size(16, 16)
                    smooth: true
                    asynchronous: true
                }

                Text {
                    Layout.fillWidth: true
                    text: root.appName
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    color: root._isCritical ? Colorscheme.current.on_error_container : Colorscheme.current.on_surface_variant
                }

                Rectangle {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    radius: 10
                    color: xMa.containsMouse ? Colorscheme.current.surface_container : 'transparent'
                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }

                    Icon {
                        icon: 'close'
                        size: 14
                        anchors.centerIn: parent
                        color: root._isCritical ? Colorscheme.current.on_error_container : Colorscheme.current.on_surface_variant
                    }

                    MouseArea {
                        id: xMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.startDismiss()
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    visible: root.bodyImage !== '' && bodyImg.status !== Image.Error
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    Layout.alignment: Qt.AlignTop
                    radius: 8
                    clip: true
                    color: 'transparent'

                    Image {
                        id: bodyImg
                        anchors.fill: parent
                        source: root.bodyImage
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        asynchronous: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    // Summary
                    Text {
                        Layout.fillWidth: true
                        visible: root.summary !== ''
                        text: root.summary
                        font.pixelSize: 13
                        font.bold: true
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        color: root._isCritical ? Colorscheme.current.on_error_container : Colorscheme.current.on_surface
                    }

                    // Body
                    Column {
                        Layout.fillWidth: true
                        visible: root.body !== ''
                        spacing: 4

                        Text {
                            id: bodyText
                            width: parent.width
                            text: root.body.replace(/<[^>]*>/g, '')
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            maximumLineCount: root._expanded ? 999 : 3
                            elide: Text.ElideRight
                            color: root._isCritical ? Colorscheme.current.on_error_container : Colorscheme.current.on_surface_variant
                        }

                        Text {
                            visible: bodyText.truncated || root._expanded
                            text: root._expanded ? '↑ Read less' : '↓ Read more'
                            font.pixelSize: 11
                            color: root._isCritical ? Colorscheme.current.on_error_container : Colorscheme.current.primary
                            opacity: readMoreMa.containsMouse ? 0.6 : 1.0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 100
                                }
                            }

                            MouseArea {
                                id: readMoreMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root._expanded = !root._expanded
                            }
                        }
                    }
                }
            }

            Flow {
                Layout.fillWidth: true
                spacing: 6
                visible: root.actions.length > 0

                Repeater {
                    model: root.actions

                    delegate: Rectangle {
                        required property var modelData

                        height: 26
                        width: Math.min(actionRow.implicitWidth + 16, 150)
                        radius: 4

                        color: actMa.containsMouse ? Colorscheme.current.primary_container : Colorscheme.current.surface_container
                        Behavior on color {
                            ColorAnimation {
                                duration: 100
                            }
                        }

                        RowLayout {
                            id: actionRow
                            anchors.centerIn: parent
                            spacing: 4

                            Icon {
                                visible: root.hasActionIcons && modelData.identifier !== '' && modelData.identifier !== 'default'
                                icon: modelData.identifier
                                size: 12
                                color: actMa.containsMouse ? Colorscheme.current.on_primary_container : Colorscheme.current.on_surface
                            }

                            Text {
                                id: actLabel
                                text: modelData.text
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                color: actMa.containsMouse ? Colorscheme.current.on_primary_container : Colorscheme.current.on_surface
                            }
                        }

                        MouseArea {
                            id: actMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                NotificationsState.invokeAction(root.notifId, modelData.identifier);
                                root.startDismiss();
                            }
                        }
                    }
                }
            }
        }
    }
}
