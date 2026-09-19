pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects

// Copied mechanism from Shibumi's FlatTintedImage: an image tinted to a
// single color (theme-aware). Shibumi uses a custom .qsb shader; we use the
// standard QtQuick ColorOverlay which produces the same tint result without
// shipping a binary shader.
Item {
  id: root

  property url source
  property color tint: "white"

  Image {
    anchors.fill: parent
    source: root.source
    fillMode: Image.PreserveAspectFit
    smooth: true
    mipmap: true
  }

  ColorOverlay {
    anchors.fill: parent
    source: parent.children[0]
    color: root.tint
  }
}
