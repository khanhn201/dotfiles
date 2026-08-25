pragma Singleton
import Quickshell

// Thin bridge for anything that needs to ask the session to lock without
// depending on LockScreen.qml directly -- that's a top-level shell.qml
// component (it owns the actual WlSessionLock), not a service, so nothing
// else should be reaching into it by id. Menus' own power-menu entry is the
// first caller; a future idle-timeout or lid-close hook would go through
// the same signal rather than each inventing its own way to reach the lock.
Singleton {
    signal lockRequested()
}
