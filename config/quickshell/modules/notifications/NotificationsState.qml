pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.config

Singleton {
    id: root

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
            root._pushNotif(notif);
        }
    }

    readonly property bool visible: root.visibleNotifs.count > 0

    property ListModel visibleNotifs: ListModel {}
    property var _queuedNotifs: []

    function _pushNotif(notif) {
        if (root.visibleNotifs.count < Config.notifications.maxVisible)
            root._showNotif(notif);
        else
            root._queuedNotifs = [...root._queuedNotifs, notif];
    }

    function _showNotif(notif) {
        const entry = { notifId: notif.id, notification: notif };
        if (Config.notifications.position.startsWith('top'))
            root.visibleNotifs.append(entry);
        else
            root.visibleNotifs.insert(0, entry);
    }

    function dismiss(notifId: int) {
        // check if the notification is visible
        for (let i = 0; i < root.visibleNotifs.count; i++) {
            const item = root.visibleNotifs.get(i);
            if (item.notifId != notifId)
                continue;

            item.notification?.dismiss();
            root.visibleNotifs.remove(i);

            if (root._queuedNotifs.length > 0) {
                root._showNotif(root._queuedNotifs[0]);
                root._queuedNotifs = root._queuedNotifs.slice(1);
            }

            return;
        }

        // check if notification is queued
        const notifIndex = root._queuedNotifs.findIndex(notif => notif.id == notifId);
        if (notifIndex >= 0) {
            root._queuedNotifs[notifIndex].dismiss();
            root._queuedNotifs = root._queuedNotifs.filter((_, i) => i != notifIndex);
        }
    }
}
