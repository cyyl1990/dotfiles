import QtQuick
import Quickshell
import qs.Commons as Commons
import qs.Ui
import Qt5Compat.GraphicalEffects

// Bap Menu — bar widget (custom "BAP" wordmark, Backsteal font, theme-aware via
// ColorOverlay tinting a white glyph PNG to the bar foreground). Hover shows a
// faint pill background (matches neighbouring widgets); a small accent dot
// under the glyph indicates the menu is open. Image sits directly in the
// BarWidget; triggerPress forwards left/right clicks.
BarWidget {
  id: root
  moduleName: "bap.menu"

  readonly property color ink: root.bar
    ? root.bar.foreground
    : Commons.Color.foreground
  readonly property color accent: Commons.Color.accent

  implicitWidth: root.vertical ? (root.bar ? root.bar.barSize : 28) : icon.width + 12
  implicitHeight: root.vertical ? icon.width + 12 : (root.bar ? root.bar.barSize : 28)

  property bool menuOpen: false

  function triggerPress(button) {
    if (!root.bar) return
    if (button === Qt.RightButton) root.bar.run("xdg-terminal-exec")
    else {
      root.menuOpen = !root.menuOpen
      root.bar.run("omarchy-shell shell toggle bap.menu '{\"menu\":\"root\"}'")
    }
  }



  FontLoader {
    id: omarchyFont
    source: Qt.resolvedUrl("assets/omarchy.ttf")
  }

  Item {
    id: icon
    anchors.centerIn: parent
    rotation: root.vertical ? -90 : 0
    height: textItem.paintedHeight
    width: textItem.paintedWidth

    Text {
      id: textItem
      text: "BAP"
      font.family: omarchyFont.name
      font.pixelSize: 26
      font.letterSpacing: 2
      anchors.centerIn: parent
      visible: false
    }

    DropShadow {
      anchors.fill: textItem
      source: textItem
      color: Qt.rgba(122/255, 162/255, 247/255, 0.45)
      radius: 12
      samples: 25
      transparentBorder: true
    }

    DropShadow {
      anchors.fill: textItem
      source: textItem
      color: Qt.rgba(255/255, 95/255, 176/255, 0.55)
      radius: 6
      samples: 13
      transparentBorder: true
    }

    LinearGradient {
      id: gradient
      anchors.fill: textItem
      source: textItem
      start: Qt.point(0, 0)
      end: Qt.point(width, 0)
      gradient: Gradient {
        GradientStop { position: 0.0; color: "#ff5fb0" }
        GradientStop { position: 0.333; color: "#bb9af7" }
        GradientStop { position: 0.667; color: "#7aa2f7" }
        GradientStop { position: 1.0; color: "#7dcfff" }
      }
    }
  }

  // Accent dot under the glyph while the menu is open
  Rectangle {
    id: dot
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 2
    width: 4
    height: 4
    radius: 2
    color: root.accent
    opacity: root.menuOpen ? 0.95 : 0
    Behavior on opacity { NumberAnimation { duration: 120 } }
  }
}
