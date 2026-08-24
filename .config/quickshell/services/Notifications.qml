// Quickshell as the desktop's own notification daemon: this claims the
// org.freedesktop.Notifications DBus name (only one process may hold it, so
// dunst -- or whatever else was -- has to not be running), and hands every
// incoming notification to NotificationPopup.qml to render in the bar's own
// style instead of a foreign daemon's.
pragma Singleton
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    // Currently-visible toasts, newest last. A plain JS array reassigned on
    // every change -- QML doesn't observe in-place array mutation, only the
    // property binding itself changing.
    property var popups: []

    function _dismiss(id) {
        root.popups = root.popups.filter(p => p.id !== id);
    }

    NotificationServer {
        id: server

        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: false
        bodyImagesSupported: true
        imageSupported: true
        actionsSupported: true
        actionIconsSupported: false
        persistenceSupported: false
        inlineReplySupported: false

        onNotification: notification => {
            // Keeps the object alive past this signal -- untracked
            // notifications are only guaranteed to live for the duration of
            // the signal that hands them over.
            notification.tracked = true;

            // A sender can replace an existing notification by reusing its
            // id (a progress update, e.g.); drop any popup already showing
            // that id before adding the new generation in its place.
            root.popups = root.popups.filter(p => p.id !== notification.id).concat([notification]);

            notification.closed.connect(reason => root._dismiss(notification.id));
        }
    }
}
