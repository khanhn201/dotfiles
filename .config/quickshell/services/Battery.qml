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

    // Empty -> full in 8 steps (Material Symbols' battery_N_bar family tops
    // out at 6, plus battery_full for the last step). The icons are the
    // upright phone-battery family, not the horizontal one -- Bar.qml
    // rotates the glyph itself 90deg instead, which keeps every fill level
    // and the dedicated charging-bolt glyphs the horizontal family doesn't
    // have.
    readonly property var dischargingIcons: [
        "battery_0", "battery_1", "battery_2", "battery_3",
        "battery_4", "battery_5", "battery_6", "battery_full"
    ]

    // Material Symbols' charging glyphs are a fixed, unevenly-spaced set
    // (20/30/50/60/80/90/full) rather than a clean ramp, so this buckets by
    // threshold instead of indexing an array.
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
