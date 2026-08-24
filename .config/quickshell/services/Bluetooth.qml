pragma Singleton
import Quickshell
import Quickshell.Bluetooth

Singleton {
    // Null until the adapter is discovered at startup (or absent entirely).
    readonly property var adapter: Bluetooth.defaultAdapter

    readonly property bool enabled: adapter?.enabled ?? false
    readonly property int count: adapter?.devices.values.filter(d => d.connected).length ?? 0
    readonly property string icon: {
        if (!enabled) return "bluetooth_off";
        return count > 0 ? "bluetooth_connected" : "bluetooth_on";
    }
}
