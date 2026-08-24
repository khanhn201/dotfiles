pragma Singleton
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    readonly property PwNode sink: Pipewire.defaultAudioSink

    readonly property int percentage: Math.round((sink?.audio?.volume ?? 0) * 100)
    readonly property bool muted: sink?.audio?.muted ?? false

    readonly property string icon: {
        if (muted) return "volume_muted"
        if (percentage >= 67) return "volume_high"
        if (percentage >= 34) return "volume_medium"
        return "volume_low"
    }

    // Pipewire nodes only stream their properties while bound to a tracker.
    PwObjectTracker { objects: sink ? [sink] : [] }
}
