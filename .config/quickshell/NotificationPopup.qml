// The notification stack, replacing dunst: toasts render here in the bar's
// own style instead of a foreign daemon's. One instance, following the
// focused monitor, same as Overlay -- notifications should appear wherever
// you're actually looking.
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import QtQuick

import "./components"
import "./services"

PanelWindow {
    id: root

    readonly property int cardWidth: 340

    screen: {
        const name = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "";
        for (const s of Quickshell.screens) {
            if (s.name === name)
                return s;
        }
        return null;
    }

    visible: Notifications.popups.length > 0
    color: "transparent"

    anchors { top: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Clear of the top strip and the right edge strip -- top-right is this
    // shell's notification corner; volume/brightness claim the middle of
    // the same edge, so the two never collide.
    margins {
        top: Theme.frameThicknessTop + Theme.gap
        right: Theme.frameThickness + Theme.gap
    }

    implicitWidth: root.cardWidth
    implicitHeight: list.contentHeight

    ListView {
        id: list

        anchors.fill: parent
        model: Notifications.popups
        spacing: Theme.gap * 2
        interactive: false

        // Newest at the top: index 0 in Notifications.popups is the oldest,
        // so read the model backwards.
        verticalLayoutDirection: ListView.BottomToTop

        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.durationMedium; easing.type: Theme.easingStandard }
            NumberAnimation { property: "x"; from: root.cardWidth; to: 0; duration: Theme.durationMedium; easing.type: Theme.easingStandard }
        }
        remove: Transition {
            NumberAnimation { property: "opacity"; to: 0; duration: Theme.durationShort }
            NumberAnimation { property: "x"; to: root.cardWidth; duration: Theme.durationShort; easing.type: Theme.easingStandard }
        }
        displaced: Transition {
            NumberAnimation { properties: "y"; duration: Theme.durationMedium; easing.type: Theme.easingStandard }
        }

        delegate: NotificationCard {
            id: delegate
            required property var modelData

            width: list.width
            notification: modelData

            onDismissed: modelData.dismiss()

            // The sender's own timeout, or a resolved default when it asks
            // for one (-1) or none is given. 0 means "never auto-expire" --
            // Critical notifications get that as their default too, since a
            // low-battery or disconnect alert going away on its own is worse
            // than one sitting until dismissed.
            Timer {
                readonly property int resolvedTimeout: {
                    if (delegate.notification.expireTimeout > 0)
                        return delegate.notification.expireTimeout;
                    if (delegate.notification.expireTimeout === 0)
                        return 0;
                    if (delegate.notification.urgency === NotificationUrgency.Critical)
                        return 0;
                    return delegate.notification.urgency === NotificationUrgency.Low ? 3000 : 5000;
                }

                running: resolvedTimeout > 0
                interval: resolvedTimeout
                onTriggered: delegate.notification.expire()
            }
        }
    }
}
