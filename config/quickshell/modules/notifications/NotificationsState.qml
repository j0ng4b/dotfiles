pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.config
import qs.services

Singleton {
    id: root

    signal notificationClosed(int notifId)

    NotificationServer {
        id: notifServer
        keepOnReload: true
        bodySupported: true
        imageSupported: true
        actionsSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        actionIconsSupported: true
        persistenceSupported: true
        bodyHyperlinksSupported: false

        onNotification: notif => {
            notif.tracked = true;

            // Keeps the object alive for actions that actually need it
            notif.Retainable.lock();
            notif.Retainable.dropped.connect(() => root._handleDropped(notif.id));

            root._liveNotifs[notif.id] = notif;
            root._pushNotif(root._snapshot(notif));
        }
    }

    property string activeScreen: ''
    readonly property bool visible: root.visibleNotifs.count > 0

    property ListModel visibleNotifs: ListModel {}
    property var _queuedNotifs: []

    // Notification object. Used only for actions
    property var _liveNotifs: ({})

    // Store notifications that the sender app itself has already closed
    property var _droppedIds: ({})

    function isActiveOn(screenName) {
        if (root.visible && (root.activeScreen == screenName || root.activeScreen == ''))
            return true;
        return false;
    }

    function _snapshot(notif) {
        const actions = (notif.actions ?? []).map(a => ({
                    identifier: a.identifier,
                    text: a.text
                }));

        return {
            notifId: notif.id,
            appName: notif.appName,
            iconSrc: notif.appIcon !== '' ? (Quickshell.iconPath(notif.appIcon) ?? '') : '',
            summary: notif.summary,
            body: notif.body,
            bodyImage: notif.image,
            urgency: notif.urgency,
            expireTimeout: notif.expireTimeout,
            hasActionIcons: notif.hasActionIcons,
            actions: actions
        };
    }

    function _pushNotif(data) {
        if (root.visibleNotifs.count === 0 && root._queuedNotifs.length === 0)
            root.activeScreen = CompositorService.focusedOutput;

        if (root.visibleNotifs.count < Config.notifications.maxVisible)
            root._showNotif(data);
        else
            root._queuedNotifs = [...root._queuedNotifs, data];
    }

    function _showNotif(data) {
        if (Config.notifications.position.startsWith('top'))
            root.visibleNotifs.append(data);
        else
            root.visibleNotifs.insert(0, data);
    }

    function invokeAction(notifId, identifier) {
        if (root._droppedIds[notifId])
            return;

        const notif = root._liveNotifs[notifId];
        const action = notif?.actions?.find(a => a.identifier === identifier);
        action?.invoke();
    }

    function _handleDropped(notifId) {
        root._droppedIds[notifId] = true;

        if (Config.notifications.ignoreAppExpireTimeout)
            return;

        for (let i = 0; i < root.visibleNotifs.count; i++) {
            if (root.visibleNotifs.get(i).notifId === notifId) {
                root.notificationClosed(notifId);
                return;
            }
        }

        root.dismiss(notifId);
    }

    function dismiss(notifId: int) {
        let handled = false;

        // check if the notification is visible
        for (let i = 0; i < root.visibleNotifs.count; i++) {
            if (root.visibleNotifs.get(i).notifId != notifId)
                continue;

            handled = true;
            root.visibleNotifs.remove(i);

            if (root._queuedNotifs.length > 0) {
                root._showNotif(root._queuedNotifs[0]);
                root._queuedNotifs = root._queuedNotifs.slice(1);
            }

            break;
        }

        // check if notification is queued
        if (!handled) {
            const notifIndex = root._queuedNotifs.findIndex(d => d.notifId == notifId);
            if (notifIndex >= 0) {
                root._queuedNotifs = root._queuedNotifs.filter((_, i) => i != notifIndex);
                handled = true;
            }
        }

        if (!handled)
            return;

        const notif = root._liveNotifs[notifId];
        const wasDroppedByApp = root._droppedIds[notifId] === true;

        if (!wasDroppedByApp)
            notif?.dismiss();

        notif?.Retainable.unlock();
        delete root._liveNotifs[notifId];
        delete root._droppedIds[notifId];

        if (root.visibleNotifs.count === 0 && root._queuedNotifs.length === 0)
            root.activeScreen = '';
    }
}
