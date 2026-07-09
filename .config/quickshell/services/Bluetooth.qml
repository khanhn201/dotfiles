pragma Singleton
import Quickshell
import Quickshell.Bluetooth
import QtQuick

Singleton {
    property bool connected: Bluetooth.defaultAdapter.enabled
    property int count: Bluetooth.defaultAdapter.devices.values.filter(d => d.connected).length ?? 0
    property string icon: {
        if (!connected) return "󰂲"
        return "󰂯"
    }

}
