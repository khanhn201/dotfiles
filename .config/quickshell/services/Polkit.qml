pragma Singleton
import Quickshell
import Quickshell.Services.Polkit

// Registers as the system's one polkit authentication agent -- replaces
// hyprpolkitagent (see hyprland.lua) so every pkexec/polkit prompt on the
// system, not just this shell's own, renders through AuthPrompt.qml instead
// of a separately-styled process.
Singleton {
    id: root

    PolkitAgent {
        id: agent
        path: "/com/nekoconn/quickshell/PolicyKit1/AuthenticationAgent"
    }

    readonly property alias flow: agent.flow
    readonly property alias isRegistered: agent.isRegistered
}
