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

    function lock() {
        if (sessionLock.locked)
            return;
        root.passwordText = "";
        sessionLock.locked = true;
        pam.start();
    }

    // One conversation, not one per screen: there is exactly one session to
    // unlock, and every monitor's surface is just a view onto the same
    // attempt.
    PamContext {
        id: pam
        config: "hyprlock"
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
                onClicked: passwordField.forceActiveFocus()
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

                    StyledRectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        tone: "surfaceContainerHigh"
                        radius: Theme.radiusMedium
                        implicitWidth: 320
                        implicitHeight: 52

                        TextInput {
                            id: passwordField

                            anchors.fill: parent
                            anchors.margins: Theme.gap * 1.5
                            verticalAlignment: TextInput.AlignVCenter
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTitleMedium
                            color: Theme.colorOnSurface
                            selectionColor: Theme.colorPrimary
                            selectedTextColor: Theme.colorOnPrimary
                            // PAM prompts are usually the password itself
                            // (masked), but a module can ask for something
                            // it wants echoed back in the clear -- follow
                            // whichever it's actually asking for.
                            echoMode: pam.responseVisible ? TextInput.Normal : TextInput.Password
                            focus: true

                            // Seeds this field from whatever's already been
                            // typed (e.g. reconnecting to an in-progress
                            // attempt), but typing breaks a plain `text:`
                            // binding permanently -- onTextEdited (user
                            // input only, never fired by the assignment
                            // below) pushes local changes out, and the
                            // Connections handler pulls remote ones back in
                            // for every field whose own binding has broken.
                            text: root.passwordText
                            onTextEdited: root.passwordText = text

                            Connections {
                                target: root
                                function onPasswordTextChanged() {
                                    if (passwordField.text !== root.passwordText)
                                        passwordField.text = root.passwordText;
                                }
                            }

                            Keys.onPressed: event => {
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

                            StyledText {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: passwordField.text === ""
                                variant: "titleMedium"
                                color: Theme.colorOnSurfaceVariant
                                opacity: 0.7
                                text: "Password"
                            }
                        }
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
