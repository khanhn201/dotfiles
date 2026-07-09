// Theme.qml
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: theme

    property int barWidth: 60
    property int gap: 4
    property int cornerRadius: 15

    // ── Core M3 seed colors (Catppuccin Mocha) ──
    property color colorPrimary: "#89b4fa"              // Blue
    property color colorOnPrimary: "#11111b"            // Crust
    property color colorPrimaryContainer: "#45475a"     // Surface1
    property color colorOnPrimaryContainer: "#89b4fa"   // Blue

    property color colorSecondary: "#cba6f7"            // Mauve
    property color colorOnSecondary: "#11111b"          // Crust
    property color colorSecondaryContainer: "#45475a"   // Surface1
    property color colorOnSecondaryContainer: "#cba6f7" // Mauve

    property color colorTertiary: "#f5c2e7"             // Pink
    property color colorOnTertiary: "#11111b"           // Crust
    property color colorTertiaryContainer: "#45475a"    // Surface1
    property color colorOnTertiaryContainer: "#f5c2e7"  // Pink

    property color colorError: "#f38ba8"                // Red
    property color colorOnError: "#11111b"              // Crust
    property color colorErrorContainer: "#45475a"       // Surface1
    property color colorOnErrorContainer: "#f38ba8"     // Red

    // ── Neutral / surface roles ──
    property color colorSurface: "#1e1e2e"              // Base
    property color colorSurfaceBright: "#585b70"        // Surface2
    property color colorSurfaceDim: "#11111b"           // Crust
    property color colorOnSurface: "#cdd6f4"            // Text
    property color colorSurfaceVariant: "#313244"       // Surface0
    property color colorOnSurfaceVariant: "#a6adc8"     // Subtext0

    property color colorSurfaceContainerLowest: "#11111b"   // Crust
    property color colorSurfaceContainerLow: "#181825"      // Mantle
    property color colorSurfaceContainer: "#1e1e2e"          // Base
    property color colorSurfaceContainerHigh: "#313244"      // Surface0
    property color colorSurfaceContainerHighest: "#45475a"   // Surface1

    property color colorOutline: "#6c7086"              // Overlay0
    property color colorOutlineVariant: "#585b70"       // Surface2

    property color colorShadow: "#11111b"               // Crust
    property color colorScrim: "#11111b"                // Crust

    property color colorInverseSurface: "#cdd6f4"       // Text
    property color colorInverseOnSurface: "#1e1e2e"     // Base
    property color colorInversePrimary: "#74c7ec"       // Sapphire (reads well on light inverse surface)

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
}
