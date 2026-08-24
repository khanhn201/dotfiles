// One notification toast. Tone follows urgency, the same idiom the bar's
// alert indicators use (Battery.low, Network disconnected) rather than a
// bespoke notification palette.
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Notifications

import "../"

StyledRectangle {
    id: card

    required property Notification notification

    signal dismissed()

    readonly property bool hasImage: notification.image !== ""
    readonly property string iconSource: hasImage ? notification.image
        : (notification.appIcon !== "" ? Quickshell.iconPath(notification.appIcon, true) : "")

    tone: {
        if (notification.urgency === NotificationUrgency.Critical) return "errorContainer";
        if (notification.urgency === NotificationUrgency.Low) return "surfaceContainer";
        return "surfaceContainerHigh";
    }
    radius: Theme.radiusLarge
    // A plain Rectangle doesn't bind its own height to implicitHeight the
    // way a Layout-managed child does -- this is a ListView delegate, which
    // reads the real height property, so it has to be set directly.
    height: layout.implicitHeight + 2 * Theme.framePadding

    // Elevation shadow deliberately left off: Shadow.qml as layer.effect on
    // a ListView delegate rendered the whole card blank -- likely a
    // layer/source auto-wiring interaction specific to this combination.
    // Worth another look, not blocking a working card.

    RowLayout {
        id: layout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: Theme.framePadding
        spacing: Theme.gap * 2

        // Sender's icon if it has one, else a generic bell -- always the
        // same fixed slot so the summary column lines up toast to toast.
        Item {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.alignment: Qt.AlignTop

            Image {
                id: iconImage
                anchors.fill: parent
                visible: card.iconSource !== ""
                source: card.iconSource
                fillMode: Image.PreserveAspectCrop
                sourceSize.width: 32
                sourceSize.height: 32

                // A real photo (image hint) reads as a thumbnail; an app's
                // own icon reads as a mark, not a photo, so only the former
                // gets rounded corners.
                layer.enabled: card.hasImage
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: Rectangle {
                        width: iconImage.width
                        height: iconImage.height
                        radius: Theme.radiusSmall
                        visible: false
                    }
                }
            }

            SvgIcon {
                anchors.centerIn: parent
                visible: card.iconSource === ""
                width: 22
                height: 22
                color: Theme.toneOnColor(card.tone)
                name: "notification"
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            StyledText {
                Layout.fillWidth: true
                variant: "labelSmall"
                color: Theme.toneOnColor(card.tone)
                opacity: 0.7
                text: notification.appName
            }

            StyledText {
                Layout.fillWidth: true
                variant: "titleSmall"
                color: Theme.toneOnColor(card.tone)
                font.bold: true
                wrapMode: Text.Wrap
                textFormat: Text.StyledText
                text: notification.summary
            }

            StyledText {
                Layout.fillWidth: true
                visible: notification.body !== ""
                variant: "bodyMedium"
                color: Theme.toneOnColor(card.tone)
                opacity: 0.85
                wrapMode: Text.Wrap
                textFormat: Text.StyledText
                maximumLineCount: 4
                elide: Text.ElideRight
                text: notification.body
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: Theme.gap
                visible: notification.actions.length > 0
                spacing: Theme.gap

                Repeater {
                    model: notification.actions

                    StyledRectangle {
                        id: actionButton
                        required property var modelData

                        tone: "surfaceContainerHighest"
                        radius: height / 2
                        implicitWidth: actionLabel.implicitWidth + 2 * Theme.gap * 2
                        implicitHeight: 28

                        StyledText {
                            id: actionLabel
                            anchors.centerIn: parent
                            variant: "labelMedium"
                            color: Theme.colorOnSurface
                            text: actionButton.modelData.text
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                actionButton.modelData.invoke();
                                card.dismissed();
                            }
                        }
                    }
                }
            }
        }

        // Dismiss. Its own hit target, not lumped into the card's -- a
        // whole-card click is ambiguous, but an X never is.
        StyledText {
            Layout.alignment: Qt.AlignTop
            variant: "labelLarge"
            color: Theme.toneOnColor(card.tone)
            opacity: closeArea.containsMouse ? 1.0 : 0.6
            text: ""

            MouseArea {
                id: closeArea
                anchors.fill: parent
                anchors.margins: -6
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: card.dismissed()
            }
        }
    }
}
