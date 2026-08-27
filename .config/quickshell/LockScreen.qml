// A quickshell-native lock screen, replacing hyprlock: same wallpaper-derived
// M3 palette, same frame vocabulary, one less separately-styled config to
// keep in sync by hand. Built on the real wlr session-lock protocol, not a
// window -- the compositor itself blocks every other surface from taking
// input while WlSessionLock.locked is true, a guarantee no ordinary
// always-on-top window could give (see WlSessionLock.secure).
//
// If this QML crashes while locked, Hyprland's own session-lock manager
// treats the lock client dying as an abandoned lock and tears it down --
// the desktop becomes visible again rather than the session being stuck
// behind a dead surface. That is a security gap worth knowing about, not a
// lockout risk: `pkill -x qs` is always a safe way back in.
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Pam
import QtQuick

import "./components"
import "./services"

Scope {
    id: root

    // The one thing every monitor's password field is kept in sync through
    // -- there's one WlSessionLockSurface (and one passwordField) per
    // monitor, independent Item trees with no other link between them, so
    // without this, typing while looking at one screen would show nothing
    // on the other.
    property string passwordText: ""
    property string pamError: ""

    function lock() {
        if (sessionLock.locked)
            return;
        root.passwordText = "";
        root.pamError = "";
        sessionLock.locked = true;
        pam.start();
    }

    // Lock on login, same as a greeter would. QS_LOCK_ON_START is set only
    // on hyprland.lua's own genuine hyprland.start exec of `qs -n` -- but a
    // *reload* (any file save Quickshell picks up, not just a manual
    // restart) reuses the same process and re-runs every Component.onCompleted
    // from scratch, and env vars don't go away on their own. Gating on the
    // env var alone re-locked the session on every single reload for the
    // rest of that process's life, well past actual login -- confirmed
    // live, this is what was really behind repeated unexpected locks this
    // session. PersistentProperties survives a reload (unlike a plain QML
    // property, which resets with the rest of the tree), so it's the one
    // thing that can actually remember "already consumed" across reloads
    // within the same process -- and it has to be checked from its own
    // `onLoaded`, not root's Component.onCompleted: rootwrapper.cpp runs
    // completeCreate() (which fires every Component.onCompleted) *before*
    // generation->onReload() restores persisted values, so checking from
    // onCompleted would always see the fresh, unrestored default.
    PersistentProperties {
        id: lockOnStartState
        reloadableId: "lockOnStartState"
        property bool consumed: false

        onLoaded: {
            if (!consumed && Quickshell.env("QS_LOCK_ON_START") === "1") {
                consumed = true;
                root.lock();
            }
        }
    }

    // One conversation, not one per screen: there is exactly one session to
    // unlock, and every monitor's surface is just a view onto the same
    // attempt.
    PamContext {
        id: pam
        // Our own service, not "hyprlock" -- hyprlock itself isn't
        // installed (this replaces it), so that PAM service name never
        // existed on this system. Without a matching /etc/pam.d file,
        // start() fails silently: responseRequired never becomes true, so
        // the password field looks alive but Enter is a permanent no-op --
        // a real lockout with no on-screen sign anything's wrong (this is
        // exactly what happened; see onError below for the fix to that
        // part).
        config: "qslock"
        user: Quickshell.env("USER")

        onCompleted: result => {
            if (result === PamResult.Success) {
                sessionLock.locked = false;
                return;
            }
            // A failed attempt ends the conversation; start a fresh one so
            // the prompt is live again instead of dead-ending here.
            root.passwordText = "";
            pam.start();
        }

        // Surface a broken PAM setup instead of a permanently-dead prompt
        // (see the config comment above) -- shown in place of the message
        // area below the password field.
        onError: error => {
            root.pamError = PamError.toString(error);
        }
    }

    WlSessionLock {
        id: sessionLock

        WlSessionLockSurface {
            id: surface

            color: Theme.colorSurface

            Image {
                anchors.fill: parent
                source: Wallpapers.currentPath ? "file://" + Wallpapers.currentPath : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            // Same role as hyprlock.conf's own background colour layer --
            // legible text over any wallpaper, not just dark ones.
            Rectangle {
                anchors.fill: parent
                color: Theme.colorScrim
                opacity: 0.55
            }

            MouseArea {
                anchors.fill: parent
                onClicked: passwordField.input.forceActiveFocus()
            }

            Column {
                anchors.centerIn: parent
                spacing: Theme.gap * 4

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.gap

                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDateTime(Clock.now, "HH:mm")
                        font.family: Theme.fontFamily
                        font.pixelSize: 96
                        color: "white"
                    }

                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDateTime(Clock.now, "dddd, d MMMM yyyy")
                        variant: "titleLarge"
                        color: "white"
                    }
                }

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.gap

                    RailField {
                        id: passwordField

                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 320
                        height: 52
                        placeholder: "Password"
                        centerText: true

                        // PAM prompts are usually the password itself
                        // (masked), but a module can ask for something it
                        // wants echoed back in the clear -- follow whichever
                        // it's actually asking for.
                        input.echoMode: pam.responseVisible ? TextInput.Normal : TextInput.Password
                        input.focus: true

                        // Seeds this field from whatever's already been
                        // typed (e.g. reconnecting to an in-progress
                        // attempt), but typing breaks a plain `text:`
                        // binding permanently -- onTextEdited (user input
                        // only, never fired by the assignment below) pushes
                        // local changes out, and the Connections handler
                        // pulls remote ones back in for every field whose
                        // own binding has broken.
                        input.text: root.passwordText
                        input.onTextEdited: root.passwordText = input.text

                        Connections {
                            target: root
                            function onPasswordTextChanged() {
                                if (passwordField.text !== root.passwordText)
                                    passwordField.text = root.passwordText;
                            }
                        }

                        input.Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                root.passwordText = "";
                                event.accepted = true;
                                return;
                            }
                            if (event.key !== Qt.Key_Return && event.key !== Qt.Key_Enter)
                                return;
                            if (pam.responseRequired && root.passwordText.length > 0)
                                pam.respond(root.passwordText);
                            event.accepted = true;
                        }
                    }

                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: root.pamError !== ""
                        variant: "bodyMedium"
                        color: Theme.colorError
                        text: root.pamError
                    }
                }
            }
        }
    }

    // Triggered by name, same as launcher/power/screenshot/commands --
    // `hyprctl dispatch 'hl.dsp.global("quickshell:lock")'`, or bind a key
    // to it the same way those are bound.
    GlobalShortcut {
        appid: "quickshell"
        name: "lock"
        onPressed: root.lock()
    }

    // The power menu's own Lock entry goes through here rather than a
    // direct reference -- see Session.qml.
    Connections {
        target: Session
        function onLockRequested() { root.lock(); }
    }
}
