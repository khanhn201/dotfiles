pragma Singleton
import Quickshell

Singleton {
    // Format at the point of use: Qt.formatDateTime(Clock.now, "HH:mm")
    readonly property date now: clock.date

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
