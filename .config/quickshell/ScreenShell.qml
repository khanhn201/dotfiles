// Everything the shell puts on one screen: the bar on the left edge (full
// height), the top bar carrying the column indicator, thin strips extending
// the frame colour along the remaining edges, and rounded cutouts over each
// screen corner.
import Quickshell

Scope {
    id: root

    required property ShellScreen modelData

    Bar { screen: root.modelData }
    TopBar { screen: root.modelData }
    EdgeStrip { screen: root.modelData; edge: "right" }
    EdgeStrip { screen: root.modelData; edge: "bottom" }

    ScreenCorner { screen: root.modelData; corner: "topLeft" }
    ScreenCorner { screen: root.modelData; corner: "topRight" }
    ScreenCorner { screen: root.modelData; corner: "bottomLeft" }
    ScreenCorner { screen: root.modelData; corner: "bottomRight" }
}
