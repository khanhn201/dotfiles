pragma Singleton
import Quickshell
import Quickshell.Services.UPower

Singleton {
    readonly property var battery: UPower.displayDevice
    readonly property real percentage: battery?.percentage ?? 0
    readonly property bool charging: battery?.state === UPowerDeviceState.Charging
        || battery?.state === UPowerDeviceState.PendingCharge
        || battery?.state === UPowerDeviceState.FullyCharged
    readonly property bool low: percentage < 0.2 && battery?.state === UPowerDeviceState.Discharging

    readonly property var dischargingIcons: [
        "battery_0", "battery_1", "battery_2", "battery_3",
        "battery_4", "battery_5", "battery_6", "battery_full"
    ]
    readonly property string icon: {
        if (!charging) {
            const idx = percentage >= 0.95 ? 7 : Math.floor(percentage * 7);
            return dischargingIcons[idx];
        }
        if (percentage < 0.25) return "battery_charging_20";
        if (percentage < 0.40) return "battery_charging_30";
        if (percentage < 0.55) return "battery_charging_50";
        if (percentage < 0.70) return "battery_charging_60";
        if (percentage < 0.85) return "battery_charging_80";
        if (percentage < 0.95) return "battery_charging_90";
        return "battery_charging_full";
    }
}
