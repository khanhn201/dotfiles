pragma Singleton
import Quickshell
import Quickshell.Services.UPower
import QtQuick


Singleton {
    readonly property var battery: UPower.displayDevice
    readonly property real percentage: battery?.percentage ?? 0.0

    readonly property string icon: {
        let p = percentage;
        let state = battery?.state;

        // Charging / plugged in
        if (state === UPowerDeviceState.Charging ||
            state === UPowerDeviceState.PendingCharge) {
            if (p >= 0.95) return "󰂅";
            if (p >= 0.90) return "󰂋";
            if (p >= 0.80) return "󰂊";
            if (p >= 0.70) return "󰢞";
            if (p >= 0.60) return "󰂉";
            if (p >= 0.50) return "󰢝";
            if (p >= 0.40) return "󰂈";
            if (p >= 0.30) return "󰂇";
            if (p >= 0.20) return "󰂆";
            return "󰢜";
        }
        if (state === UPowerDeviceState.FullyCharged)
            return "󰂅";

        // Discharging
        if (p >= 0.95) return "󰁹";
        if (p >= 0.90) return "󰂂";
        if (p >= 0.80) return "󰂁";
        if (p >= 0.70) return "󰂀";
        if (p >= 0.60) return "󰁿";
        if (p >= 0.50) return "󰁾";
        if (p >= 0.40) return "󰁽";
        if (p >= 0.30) return "󰁼";
        if (p >= 0.20) return "󰁻";
        return "󰁺";
    }
}
