pragma Singleton
import Quickshell
import Quickshell.Networking

Singleton {
    readonly property bool connected: Networking.connectivity === NetworkConnectivity.Full

    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var network: wifi?.networks.values.find(n => n.connected) ?? null

    readonly property string ssid: network?.name ?? "Disconnected"
    readonly property real strength: network?.signalStrength ?? 0

    // Three non-off steps, not four -- the "wifi" icon family only goes to
    // 2 bars plus full.
    readonly property string icon: {
        if (!connected) return "wifi_off";
        if (strength > 0.66) return "wifi_high";
        if (strength > 0.33) return "wifi_medium";
        return "wifi_low";
    }
}
