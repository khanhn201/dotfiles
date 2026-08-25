// Theme.qml
pragma Singleton
import Quickshell
import QtQuick

import "./services"

Singleton {
    id: theme

    // The one dial that resizes the whole bar: the clock and date tiles are
    // set at this size, and everything else -- the rail's thickness, the
    // icon-rail well, barWidth itself -- is measured or derived from what
    // that renders as, not set independently. Turn this one knob to scale
    // the sidebar up or down as a unit.
    property int mainFontSize: 32

    // The clock and date tiles are transparent -- no pill of their own -- so
    // their true visible width is just their digits, not whatever column
    // they happen to lay out in. Measured live via TextMetrics rather than a
    // pixel-measured literal, so it tracks mainFontSize/fontFamily instead of
    // silently drifting out of sync when either changes.
    TextMetrics {
        id: clockDigitsMetrics
        font.family: theme.fontFamily
        font.pixelSize: theme.mainFontSize
        text: "00"
    }
    readonly property int railThickness: Math.ceil(clockDigitsMetrics.width)

    // Space *between* sibling components in the bar (workspace rail, media
    // pill, each indicator).
    property int gap: 10
    // Space between a frame's own edge and the content inside it -- the media
    // pill, the date tile, the dot rail's own well. Deliberately larger than
    // gap: content should never sit flush against a rounded shape's own
    // boundary, which gap alone was too thin to prevent.
    property int framePadding: 10
    // Wide enough to hold the clock/date/rail column plus its own padding on
    // each side, and not a separate number that has to be kept in sync with
    // them by hand.
    readonly property int barWidth: railThickness + 2 * framePadding
    property int cornerRadius: 15
    property int frameThickness: 10
    // The media pill's own height -- Bar.qml's the only reader, but it's a
    // deliberate size (not derived from anything else the way barWidth is),
    // so it lives here rather than as a literal sitting in the layout file.
    property int mediaPillHeight: 420

    // Dot-rail metrics, shared by the workspace slider and the column
    // indicator so the two instruments stay identical. The top strip has to
    // be thick enough to hold a horizontal rail, so it derives its own
    // thickness. The dot is sized down to fit railThickness with real gutter
    // around it, rather than the well being stretched out to the dot.
    // Rounded down to an even number: DotRail's half-cut dot is built from a
    // flat rectangle stacked on a clipped circle, and an odd width puts the
    // circle's own centre on a half-pixel -- Qt rounds that differently for
    // the curve than for the flat rectangle's edge, so the two pieces come
    // out with centres 0.5px apart. Barely visible as a systemic offset, but
    // very visible as a seam exactly where the flat top meets the curve.
    property int railDotActive: railThickness
    property int railIcon: railDotActive*0.9
    property int railDotIdle: 14
    property int railDotSpacing: 10
    readonly property int railGutter: (railThickness - railDotActive) / 2
    // How far the well and each dot run straight before curving into their
    // half-cut bottom, instead of the curve starting right at the flat top.
    property int railHalfCutExtension: 6
    // DotRail's halfCut mode draws the well as its own bottom half only --
    // a real flat top edge, a straight run, then a semicircular bottom --
    // so this only needs to fit that (plus the straight extension, sized off
    // the well's own radius) and a single framePadding below it, not a full
    // thickness plus padding on both sides.
    readonly property int frameThicknessTop: Math.round((railThickness / 2) + railHalfCutExtension) + framePadding

    // Which M3 tone the recessed "rail" reads as everywhere it shows up:
    // DotRail's well, IconRail's well, MediaPill idle, LevelIndicator/
    // LevelOSD's track. A tone *name* -- a tonePairs key below, not a colour
    // literal -- so trying a different M3 role for the whole set at once is
    // one line here instead of hunting down every Theme.colorX literal
    // across the shell. colorRail/colorOnRail resolve it through the same
    // toneColor/toneOnColor pair every other tone-driven surface uses, so
    // content sitting on the rail keeps proper M3 contrast if this changes.
    property string railColor: "surfaceContainerLowest"
    readonly property color colorRail: toneColor(railColor)
    readonly property color colorOnRail: toneOnColor(railColor)

    // ── Colour ──
    // Every role below is derived from the wallpaper by
    // quickshell/scripts/m3-from-wallpaper.py and lives in the generated
    // Colors.qml, which Hyprland (colors.lua, for its own border colours)
    // and hyprlock (colors.conf, if ever run manually) read from too, so
    // the whole desktop moves together. Wallpapers.qml's apply() and
    // ThemeMode.qml's toggle() both call it directly; nothing here should
    // be a literal.
    //
    // Which of Colors.qml's two schemes is live: ThemeMode.isDark is a plain
    // mutable property (unlike everything Colors.qml itself exposes, which is
    // regenerated wholesale and read-only), so toggling it here cascades
    // through every colorXxx property below and every component bound to one,
    // in the same frame -- no file write, no restart.
    readonly property var scheme: ThemeMode.isDark ? Colors.m3Dark : Colors.m3Light

    readonly property color colorPrimary: scheme.primary
    readonly property color colorOnPrimary: scheme.onPrimary
    readonly property color colorPrimaryContainer: scheme.primaryContainer
    readonly property color colorOnPrimaryContainer: scheme.onPrimaryContainer

    readonly property color colorSecondary: scheme.secondary
    readonly property color colorOnSecondary: scheme.onSecondary
    readonly property color colorSecondaryContainer: scheme.secondaryContainer
    readonly property color colorOnSecondaryContainer: scheme.onSecondaryContainer

    readonly property color colorTertiary: scheme.tertiary
    readonly property color colorOnTertiary: scheme.onTertiary
    readonly property color colorTertiaryContainer: scheme.tertiaryContainer
    readonly property color colorOnTertiaryContainer: scheme.onTertiaryContainer

    readonly property color colorError: scheme.error
    readonly property color colorOnError: scheme.onError
    readonly property color colorErrorContainer: scheme.errorContainer
    readonly property color colorOnErrorContainer: scheme.onErrorContainer

    readonly property color colorSurface: scheme.surface
    readonly property color colorSurfaceBright: scheme.surfaceBright
    readonly property color colorSurfaceDim: scheme.surfaceDim
    readonly property color colorOnSurface: scheme.onSurface
    readonly property color colorSurfaceVariant: scheme.surfaceVariant
    readonly property color colorOnSurfaceVariant: scheme.onSurfaceVariant

    readonly property color colorSurfaceContainerLowest: scheme.surfaceContainerLowest
    readonly property color colorSurfaceContainerLow: scheme.surfaceContainerLow
    readonly property color colorSurfaceContainer: scheme.surfaceContainer
    readonly property color colorSurfaceContainerHigh: scheme.surfaceContainerHigh
    readonly property color colorSurfaceContainerHighest: scheme.surfaceContainerHighest

    readonly property color colorOutline: scheme.outline
    readonly property color colorOutlineVariant: scheme.outlineVariant

    readonly property color colorShadow: scheme.shadow
    readonly property color colorScrim: scheme.scrim

    readonly property color colorInverseSurface: scheme.inverseSurface
    readonly property color colorInverseOnSurface: scheme.inverseOnSurface
    readonly property color colorInversePrimary: scheme.inversePrimary

    // The bar, the three edge strips and the four corners are one continuous
    // frame around the screen, so they all read this single token rather than
    // each naming a role. Google's own NavigationRail -- the closest real M3
    // component to this bar -- uses plain `surface` for exactly this, and
    // reserves `secondary` for the small active-item indicator only; painting
    // the whole frame in an accent colour was fighting the spec. Retint by
    // changing this one line.
    readonly property color colorFrame: colorSurfaceContainerHighest
    // Paired text/icon colour for anything sitting directly on colorFrame with
    // no pill of its own behind it (the CPU/volume/clock readouts, in their
    // resting state -- they are data, not buttons, so they get no separate
    // background). Keep this in sync with colorFrame above.
    readonly property color colorOnFrame: colorOnSurface

    // ── Shape scale ──
    property int radiusNone: 0
    property int radiusExtraSmall: 4
    property int radiusSmall: 8
    property int radiusMedium: 12
    property int radiusLarge: 16
    property int radiusExtraLarge: 28
    property int radiusFull: 9999
    property int radius: radiusMedium

    // ── Typography ──
    property string fontFamily: "JetBrains Mono"

    property int fontSizeDisplayLarge: 57
    property int fontSizeDisplayMedium: 45
    property int fontSizeDisplaySmall: 36
    property int fontSizeHeadlineLarge: 32
    property int fontSizeHeadlineMedium: 28
    property int fontSizeHeadlineSmall: 24
    property int fontSizeTitleLarge: 22
    property int fontSizeTitleMedium: 16
    property int fontSizeTitleSmall: 14
    property int fontSizeBodyLarge: 16
    property int fontSizeBodyMedium: 14
    property int fontSizeBodySmall: 12
    property int fontSizeLabelLarge: 14
    property int fontSizeLabelMedium: 12
    property int fontSizeLabelSmall: 11
    property int fontSize: fontSizeBodyMedium

    // ── Motion ──
    property int durationShort: 100
    property int durationMedium: 250
    property int durationLong: 400
    property int easingStandard: Easing.InOutCubic

    // ── Elevation ──
    property int shadowSpread: 20
    property real shadowBlur: 0.6
    property real shadowOpacity: 0.35

    // ── Tone pairs (M3 color role -> [background, content]) ──
    readonly property var tonePairs: ({
        surface: [colorSurface, colorOnSurface],
        surfaceVariant: [colorSurfaceVariant, colorOnSurfaceVariant],
        surfaceDim: [colorSurfaceDim, colorOnSurface],
        surfaceBright: [colorSurfaceBright, colorOnSurface],
        surfaceContainerLowest: [colorSurfaceContainerLowest, colorOnSurface],
        surfaceContainerLow: [colorSurfaceContainerLow, colorOnSurface],
        surfaceContainer: [colorSurfaceContainer, colorOnSurface],
        surfaceContainerHigh: [colorSurfaceContainerHigh, colorOnSurfaceVariant],
        surfaceContainerHighest: [colorSurfaceContainerHighest, colorOnSurface],
        primary: [colorPrimary, colorOnPrimary],
        primaryContainer: [colorPrimaryContainer, colorOnPrimaryContainer],
        secondary: [colorSecondary, colorOnSecondary],
        secondaryContainer: [colorSecondaryContainer, colorOnSecondaryContainer],
        tertiary: [colorTertiary, colorOnTertiary],
        tertiaryContainer: [colorTertiaryContainer, colorOnTertiaryContainer],
        error: [colorError, colorOnError],
        errorContainer: [colorErrorContainer, colorOnErrorContainer]
    })

    function toneColor(tone: string): color {
        return (tonePairs[tone] ?? tonePairs.surfaceContainerHigh)[0];
    }

    function toneOnColor(tone: string): color {
        return (tonePairs[tone] ?? tonePairs.surfaceContainerHigh)[1];
    }
}
