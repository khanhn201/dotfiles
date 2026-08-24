// The sidebar for one screen: a stack of indicator pills, each bound
// directly to a service singleton.
import Quickshell
import QtQuick
import QtQuick.Layouts

import "./components"
import "./services"

PanelWindow {
    id: bar

    // The bar sits on a bright surface container rather than the darkest
    // neutral, so it reads as a raised surface over the wallpaper. Shared with
    // the edge strips and corners via Theme.colorFrame.
    color: Theme.colorFrame
    implicitWidth: Theme.barWidth

    // An indicator pill with fixed-width icon and value cells, so the two
    // columns stay aligned across every module in the bar.
    component Indicator: StyledRectangle {
        id: pill

        property alias icon: iconGlyph.name
        property alias value: valueLabel.text

        Layout.fillWidth: true
        implicitHeight: 30
        // Small standalone chips read M3's shape scale as "fully rounded"
        // for exactly this reason: at any partial radius, a fixed pill
        // height leaves too little straight edge for the corner curve not to
        // crowd the label sitting inside it. Rounding to a full stadium side-
        // steps the padding-vs-radius arithmetic entirely -- the curve only
        // ever eats into the corners, never the flat run down the middle
        // where the centered label actually sits.
        radius: height / 2

        Row {
            anchors.centerIn: parent
            spacing: Theme.gap

            SvgIcon {
                id: iconGlyph
                width: 18
                height: 18
                color: pill.contentColor
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                id: valueLabel
                width: 28
                variant: "labelLarge"
                color: pill.contentColor
                horizontalAlignment: Text.AlignRight
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // Bluetooth and network are both a single glyph's worth of state -- on/off,
    // signal strength -- with no reading worth a pill of their own, so they
    // sit in the workspace rail's own well instead: same formulas, same
    // Theme tokens, same radius-from-thickness, right down to the cell a dot
    // would occupy. Cosmetic only -- there's no dot data here, just two icons
    // standing in the two cells a two-item DotRail would have drawn.
    component IconRail: Item {
        id: iconRail

        property alias topIcon: topGlyph.name
        property color topColor: Theme.colorOnSurfaceVariant
        property alias bottomIcon: bottomGlyph.name
        property color bottomColor: Theme.colorOnSurfaceVariant

        readonly property int gutter: Theme.railGutter
        readonly property int cell: Theme.railIcon
        readonly property int dotSpacing: Theme.railDotSpacing
        readonly property int thickness: Theme.railThickness
        readonly property int span: 2 * Theme.railDotActive + dotSpacing + 2 * gutter

        Layout.alignment: Qt.AlignHCenter
        implicitWidth: thickness
        implicitHeight: span

        Rectangle {
            anchors.centerIn: parent
            width: iconRail.implicitWidth
            height: iconRail.implicitHeight
            radius: iconRail.thickness / 2
            color: Theme.colorSurfaceContainer

            Column {
                anchors.centerIn: parent
                spacing: iconRail.dotSpacing

                SvgIcon {
                    id: topGlyph
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: iconRail.cell
                    height: iconRail.cell
                    color: iconRail.topColor
                }

                SvgIcon {
                    id: bottomGlyph
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: iconRail.cell
                    height: iconRail.cell
                    color: iconRail.bottomColor
                }
            }
        }
    }

    anchors {
        top: true
        bottom: true
        left: true
    }

    // Explicit, not Auto: a panel anchored to three edges at once left its
    // own exclusive-zone direction ambiguous to the compositor, and which way
    // it resolved changed between runs -- sometimes reserving the width as
    // intended, sometimes reserving along top/bottom too and getting shrunk
    // to nothing in return. Pinning both properties removes the ambiguity:
    // Bar always reserves exactly its width, on the left, full stop.
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: Theme.barWidth

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.framePadding
        anchors.rightMargin: Theme.framePadding
        anchors.bottomMargin: Theme.framePadding
        // The rail is already centered horizontally in Bar's full width, which
        // puts (barWidth - railThickness) / 2 of empty space to its left
        // (Bar's own margins cancel out of that: wider outer margin, narrower
        // centering gap, same total either way). Using that same value as the
        // top margin means the first dot sits exactly as far from Bar's top
        // edge as it does from its left edge.
        anchors.topMargin: (Theme.barWidth - Theme.railThickness) / 2
        spacing: Theme.gap

        DotRail {
            id: rail
            anchors.horizontalCenter: parent.horizontalCenter
            vertical: true
            // One dot per workspace on this screen, true on the one being shown.
            dots: Workspaces.workspaceDotsFor(bar.screen)
            onActivated: index => Workspaces.focusWorkspace(bar.screen, index)
        }

        // Equal spacers above and below park the media pill in the middle of
        // the bar, between the workspace rail at the top and the readouts at
        // the bottom.
        Item { Layout.fillHeight: true }

        MediaPill {
            Layout.fillWidth: true
            Layout.preferredHeight: 210
        }

        Item { Layout.fillHeight: true }

        // Its own layout, spaced looser than Theme.gap: these eight rows read
        // as one solid readout block at the between-component gap, since each
        // row is nothing but a line of text with no pill behind it to break
        // it up visually.
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.gap * 2

            Indicator {
                tone: "surfaceContainerHighest"
                color: "transparent"
                contentColor: Theme.colorOnFrame
                icon: Cpu.icon
                value: Cpu.percentage
            }

            Indicator {
                tone: "surfaceContainerHighest"
                color: "transparent"
                contentColor: Theme.colorOnFrame
                icon: Memory.icon
                value: Memory.percentage
            }

            Indicator {
                tone: "surfaceContainerHighest"
                color: "transparent"
                contentColor: Theme.colorOnFrame
                icon: Keyboard.icon
                value: Keyboard.layout
            }

            Indicator {
                tone: Volume.muted ? "primary" : "surfaceContainerHighest"
                color: Volume.muted ? Theme.toneColor(tone) : "transparent"
                contentColor: Volume.muted ? Theme.toneOnColor(tone) : Theme.colorOnFrame
                icon: Volume.icon
                value: Volume.percentage
            }

            Indicator {
                tone: "surfaceContainerHighest"
                color: "transparent"
                contentColor: Theme.colorOnFrame
                icon: Brightness.icon
                value: Brightness.percentage
            }

            Indicator {
                tone: Battery.low ? "error" : "surfaceContainerHighest"
                color: Battery.low ? Theme.toneColor(tone) : "transparent"
                contentColor: Battery.low ? Theme.toneOnColor(tone) : Theme.colorOnFrame
                icon: Battery.icon
                value: Math.round(Battery.percentage * 100)
            }
        }
        IconRail {
            topIcon: Bluetooth.icon
            bottomIcon: Network.icon
            bottomColor: Network.connected ? Theme.colorOnFrame : Theme.colorError
        }

        // Date as a calendar tile. The day number is set at the clock's size,
        // and every other line is sized so it renders exactly as wide as those
        // two digits, giving one flush-edged block. In a monospace face width is
        // characters x advance x size and the advance cancels, so equal width
        // just means size x characters is constant.
        StyledRectangle {
            id: dateTile

            readonly property int daySize: Theme.mainFontSize

            function sizeForChars(chars: int): int {
                return Math.round(dateTile.daySize * 2 / chars);
            }

            tone: "surfaceContainerHighest"
            color: "transparent"
            Layout.fillWidth: true
            implicitHeight: dateColumn.implicitHeight + 2 * Theme.framePadding

            Column {
                id: dateColumn
                anchors.centerIn: parent

                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: dateTile.sizeForChars(3)
                    color: Theme.colorOnFrame
                    text: Qt.formatDateTime(Clock.now, "ddd").toUpperCase()
                }

                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: dateTile.daySize
                    color: Theme.colorOnFrame
                    text: Qt.formatDateTime(Clock.now, "dd")
                }

                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: dateTile.sizeForChars(2)
                    color: Theme.colorOnFrame
                    text: Qt.formatDateTime(Clock.now, "MM")
                }

                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: dateTile.sizeForChars(4)
                    color: Theme.colorOnFrame
                    text: Qt.formatDateTime(Clock.now, "yyyy")
                }
            }
        }

        StyledRectangle {
            tone: "surfaceContainerHighest"
            color: "transparent"
            contentColor: Theme.colorOnFrame
            Layout.fillWidth: true
            // Sized from the label's own two-line height, same as the date
            // tile above it, instead of a guessed constant.
            implicitHeight: contentHeight
            fontSize: Theme.mainFontSize
            text: Qt.formatDateTime(Clock.now, "HH\nmm")
        }
    }
}
