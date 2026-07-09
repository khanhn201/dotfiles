// Network.qml
pragma Singleton
import Quickshell
import Quickshell.Networking
import QtQuick

Singleton {
    property bool connected: Networking.connectivity === NetworkConnectivity.Full
    property string ssid: Networking.devices.values[1]?.networks.values[0]?.name ?? "Disconnected"
    property real strength: Networking.devices.values[1]?.networks.values[0]?.signalStrength ?? 0.0
    property string icon: {
        if (!connected) return "󰤯"
        if (strength > 0.75) return "󰤨"
        if (strength > 0.50) return "󰤥"
        if (strength > 0.25) return "󰤢"
        return "󰤟"
    }
}
