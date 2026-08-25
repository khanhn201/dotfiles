import Quickshell

Scope {
    Variants {
        model: Quickshell.screens

        ScreenShell {}
    }

    // One instance, not one per screen: it follows the focused monitor.
    Overlay {}
    NotificationPopup {}
    LevelOSD {}
    LockScreen {}
}
