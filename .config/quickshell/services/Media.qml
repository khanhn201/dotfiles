pragma Singleton
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property var players: Mpris.players.values

    // Prefer a player that's actually playing; otherwise show the first one.
    readonly property var player: {
        for (const p of players)
            if (p.isPlaying) return p;
        return players[0] ?? null;
    }

    readonly property bool active: player !== null
    readonly property bool playing: player?.isPlaying ?? false
    readonly property string title: player?.trackTitle ?? ""
    readonly property string artist: player?.trackArtist ?? ""

    readonly property string icon: {
        if (!active) return "media_stopped";
        return playing ? "media_playing" : "media_paused";
    }

    function toggle() {
        if (player?.canTogglePlaying) player.togglePlaying();
    }
    function next() {
        if (player?.canGoNext) player.next();
    }
    function previous() {
        if (player?.canGoPrevious) player.previous();
    }
}
