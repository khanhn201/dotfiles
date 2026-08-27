// One password prompt for anything the system or this shell needs elevated
// access for -- a real polkit request (Polkit.qml's agent, replacing
// hyprpolkitagent system-wide) or a sudo-backed command that can't go
// through polkit (Sudo.qml). Same bottom-sheet the launcher/power/screenshot
// menu uses (Overlay.qml's card): rounded where it meets open screen, square
// where it's flush against the edge strips, sliding up from fully offscreen.
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import "./components"
import "./services"

PanelWindow {
    id: root

    // Normalizes whichever source has a live request into one shape, so
    // everything below only ever deals with one of these instead of
    // branching on which backend is active.
    readonly property var active: Polkit.flow ? {
        message: Polkit.flow.message,
        error: Polkit.flow.supplementaryIsError ? Polkit.flow.supplementaryMessage : "",
        responseVisible: Polkit.flow.responseVisible,
        submit: pw => Polkit.flow.submit(pw),
        cancel: () => Polkit.flow.cancelAuthenticationRequest()
    } : (Sudo.pendingCommand ? {
        message: Sudo.message,
        error: Sudo.errorMessage,
        responseVisible: false,
        submit: pw => Sudo.submit(pw),
        cancel: () => Sudo.cancel()
    } : null)

    readonly property bool wantOpen: active !== null
    readonly property bool fullscreen: Hyprland.focusedMonitor?.activeWorkspace?.hasFullscreen ?? false

    property string passwordText: ""

    onWantOpenChanged: {
        if (wantOpen) {
            root.passwordText = "";
            passwordField.forceActiveFocus();
        } else {
            hideLinger.restart();
        }
    }

    // A brand new AuthFlow (polkit retrying after a wrong password, or a
    // fresh request) starts with its own identity unselected -- this is a
    // single-user desktop, so there's never a real choice to make, just one
    // identity to accept.
    Connections {
        target: Polkit
        function onFlowChanged() {
            if (Polkit.flow && Polkit.flow.identities.length > 0 && !Polkit.flow.selectedIdentity)
                Polkit.flow.selectedIdentity = Polkit.flow.identities[0];
        }
    }

    visible: wantOpen || hideLinger.running
    color: "transparent"

    Timer { id: hideLinger; interval: Theme.durationLong }

    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    MouseArea {
        anchors.fill: parent
        onClicked: root.active?.cancel()
    }

    StyledRectangle {
        id: card

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: 420
        height: 220

        transform: Translate {
            y: root.wantOpen ? 0 : card.height

            Behavior on y {
                NumberAnimation { duration: Theme.durationLong; easing.type: Theme.easingStandard }
            }
        }

        color: Theme.colorFrame
        radius: Theme.cornerRadius
        bottomLeftRadius: 0
        bottomRightRadius: 0

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.framePadding
            spacing: Theme.gap * 2

            StyledText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                variant: "titleMedium"
                color: Theme.colorOnFrame
                text: root.active?.message ?? ""
            }

            StyledRectangle {
                Layout.fillWidth: true
                tone: "surfaceContainerHigh"
                radius: Theme.radiusMedium
                implicitHeight: 44

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
                    echoMode: (root.active && root.active.responseVisible) ? TextInput.Normal : TextInput.Password

                    text: root.passwordText
                    onTextEdited: root.passwordText = text

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            root.passwordText = "";
                            root.active?.cancel();
                            event.accepted = true;
                            return;
                        }
                        if (event.key !== Qt.Key_Return && event.key !== Qt.Key_Enter)
                            return;
                        if (root.passwordText.length > 0)
                            root.active?.submit(root.passwordText);
                        root.passwordText = "";
                        event.accepted = true;
                    }
                }
            }

            StyledText {
                Layout.fillWidth: true
                Layout.minimumHeight: contentHeight
                wrapMode: Text.Wrap
                visible: (root.active?.error ?? "") !== ""
                variant: "bodyMedium"
                color: Theme.colorError
                text: root.active?.error ?? ""
            }

            Item { Layout.fillHeight: true }
        }
    }

    Item {
        x: card.x - Theme.cornerRadius
        width: Theme.cornerRadius
        height: Theme.cornerRadius
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.fullscreen ? 0 : Theme.frameThickness

        transform: Translate {
            y: root.wantOpen ? 0 : Theme.cornerRadius

            Behavior on y {
                NumberAnimation { duration: Theme.durationLong; easing.type: Theme.easingStandard }
            }
        }

        CornerWedge { anchors.fill: parent; corner: "bottomRight" }
    }

    Item {
        x: card.x + card.width
        width: Theme.cornerRadius
        height: Theme.cornerRadius
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.fullscreen ? 0 : Theme.frameThickness

        transform: Translate {
            y: root.wantOpen ? 0 : Theme.cornerRadius

            Behavior on y {
                NumberAnimation { duration: Theme.durationLong; easing.type: Theme.easingStandard }
            }
        }

        CornerWedge { anchors.fill: parent; corner: "bottomLeft" }
    }
}
