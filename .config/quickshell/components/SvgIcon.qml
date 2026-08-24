// A themed icon rendered from a vendored Material Symbols glyph (Icons.qml).
// Every glyph is a single flat-colour path, so it's re-tinted by rewriting
// the SVG's own fill attribute and handing the result to Image as a data
// URI -- simpler and cheaper than a MultiEffect colorize pass for something
// that never needs more than one colour.
import QtQuick
import "../"

Image {
    id: root

    property string name: ""
    property color color: Theme.colorOnSurface

    function _hex(c: color): string {
        const h = v => Math.round(v * 255).toString(16).padStart(2, "0");
        return "#" + h(c.r) + h(c.g) + h(c.b);
    }

    readonly property string _raw: root.name !== "" ? (Icons.svg[root.name] ?? "") : ""
    readonly property string _tinted: root._raw !== ""
        ? root._raw.replace('fill="#000000"', 'fill="' + root._hex(root.color) + '"')
        : ""

    fillMode: Image.PreserveAspectFit
    smooth: true
    // Fixed, not derived from width/height: binding sourceSize to this same
    // item's own display size fed a loop through Image's implicitWidth (the
    // Material Symbols source is an 0..960 viewBox, so an unsettled width
    // briefly decoded at a wildly wrong scale) -- ColumnLayout in MediaPill
    // spammed QQuickItem::polish() loop warnings until this was decoupled.
    // Every icon here is simple flat-colour art, so one oversized raster
    // covers every size this shell actually displays it at.
    sourceSize: Qt.size(64, 64)
    source: root._tinted !== "" ? "data:image/svg+xml;utf8," + encodeURIComponent(root._tinted) : ""
}
