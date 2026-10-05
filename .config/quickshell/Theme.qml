// Theme.qml
pragma Singleton
import Quickshell
import QtQuick

import "./services"

Singleton {
    id: theme

    // -- Sizing --
    property int railThickness: 32

    property int gap: 10

    property int framePadding: 10
    property int barWidth: railThickness + 2 * framePadding
    property int radius: railThickness/2
    property int frameThickness: 16
    property int mediaPillHeight: 420

    property int railDotActive: railThickness
    property int railIcon: railDotActive
    property int railDotIdle: 14
    property int railDotSpacing: 10
    property int railGutter: (railThickness - railDotActive) / 2

    property int railHalfCutExtension: 0
    property int frameThicknessTop: (railThickness / 2) + railHalfCutExtension + framePadding


    // -- Color --
    property string railColor: "surfaceContainerLowest"
    property color colorRail: toneColor(railColor)
    property color colorOnRail: toneOnColor(railColor)
    property string frameColor: "surfaceContainerHighest"
    property color colorFrame: toneColor(frameColor)
    property color colorOnFrame: toneOnColor(frameColor)



    // ── Animation ──
    property int durationShort: 100
    property int durationMedium: 250
    property int durationLong: 400
    property int easingStandard: Easing.InOutCubic


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





    // -- M3 Color --
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




    // ── Tone pairs (M3 color role -> [background, content]) ──
    readonly property var tonePairs: ({
        surface: [colorSurface, colorOnSurface],
        surfaceVariant: [colorSurfaceVariant, colorOnSurfaceVariant],
        surfaceDim: [colorSurfaceDim, colorOnSurface],
        surfaceBright: [colorSurfaceBright, colorOnSurface],
        surfaceContainerLowest: [colorSurfaceContainerLowest, colorOnSurface],
        surfaceContainerLow: [colorSurfaceContainerLow, colorOnSurface],
        surfaceContainer: [colorSurfaceContainer, colorOnSurface],
        surfaceContainerHigh: [colorSurfaceContainerHigh, colorOnSurface],
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
