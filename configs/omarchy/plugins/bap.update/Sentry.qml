import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Ui

// Bap Update Sentry overlay: pending repo updates (risky first), AUR updates,
// and .pacnew files. Arch news removed by design.
Item {
  id: root

  property var shell: null
  property var manifest: null

  property bool opened: false
  property bool loading: false
  property bool updatesError: false
  property var updates: []
  property var aur: []
  property var pacnews: []
  property var themes: []
  property var plugins: []
  property string generatedAt: ""

  readonly property string helperPath: Qt.resolvedUrl("sentry-check.py").toString().replace(/^file:\/\//, "")

  property color background: Color.menu.background
  property color foreground: Color.menu.text
  property color borderColor: Color.menu.border
  property var borderSpec: Border.surfaceSpec("menu", "border", borderColor, Math.max(1, Style.space(2)))
  property color scrim: Color.menu.scrim
  property color selectedBackground: Color.menu.selectedBackground
  property color selectedText: Color.menu.selectedText
  property color urgent: Color.urgent
  readonly property int cornerRadius: Style.cornerRadius
  property string fontFamily: Style.font.menuFamily
  property int contentMargin: Style.spacing.panelPadding
  property int cardWidth: Math.min(Style.space(440), panel.width - Style.gapsOut * 2)
  property int cardHeight: Math.min(Style.space(520), panel.height - Style.gapsOut * 2)

  property string refreshMode: "auto"

  function open(payloadJson) {
    root.opened = true
    cachedProc.running = false
    cachedProc.running = true
    root.refreshMode = "auto"
    root.refresh()
    flick.contentY = 0
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.opened = false
  }

  function dismiss() {
    root.opened = false
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "bap.update")
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  function refresh() {
    if (fullProc.running) return
    root.loading = true
    fullProc.running = false
    fullProc.running = true
  }

  function apply(text) {
    try {
      var s = JSON.parse(text)
      root.updatesError = s.updatesError === true
      root.pacnews = s.pacnew || []
      root.themes = s.themes || []
      root.plugins = s.plugins || []
      var ups = (s.updates || []).slice()
      ups.sort(function(a, b) {
        if (a.risky !== b.risky) return a.risky ? -1 : 1
        return a.name < b.name ? -1 : 1
      })
      root.updates = ups
      var a = (s.aur || []).slice()
      a.sort(function(x, y) {
        if (x.risky !== y.risky) return x.risky ? -1 : 1
        return x.name < y.name ? -1 : 1
      })
      root.aur = a
      if (s.generatedAt)
        root.generatedAt = new Date(s.generatedAt * 1000).toLocaleTimeString(Qt.locale(), "hh:mm")
    } catch (e) {
      console.warn("bap.update overlay: bad state json: " + e)
    }
  }

  function riskyCount() {
    var n = 0
    for (var i = 0; i < updates.length; i++) if (updates[i].risky) n++
    for (var j = 0; j < aur.length; j++) if (aur[j].risky) n++
    return n
  }

  function summaryText() {
    if (root.updatesError) {
      var errorHint = " - check ~/.cache/bap-update-sentry/last-error.log"
      return "Update check failed" + errorHint + " — showing last known state"
    }
    var parts = []
    parts.push(root.updates.length + " repo update" + (root.updates.length === 1 ? "" : "s"))
    if (root.aur.length > 0) parts.push(root.aur.length + " AUR update" + (root.aur.length === 1 ? "" : "s"))
    if (riskyCount() > 0) parts.push(riskyCount() + " risky")
    if (root.pacnews.length > 0) parts.push(root.pacnews.length + " .pacnew")
    if (root.themes.length > 0) parts.push(root.themes.length + " theme update" + (root.themes.length === 1 ? "" : "s"))
    if (root.plugins.length > 0) parts.push(root.plugins.length + " plugin update" + (root.plugins.length === 1 ? "" : "s"))
    return parts.join("  •  ") + (root.generatedAt ? "   (checked " + root.generatedAt + ")" : "")
  }

  function runUpdate() {
    root.dismiss()
    Quickshell.execDetached(["omarchy-launch-floating-terminal-with-presentation", "omarchy-update"])
  }

  Process {
    id: cachedProc
    command: ["python3", root.helperPath, "cached"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.apply(text)
    }
  }

  Process {
    id: fullProc
    command: ["python3", root.helperPath, root.refreshMode]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.loading = false
        root.apply(text)
      }
    }
  }

  IpcHandler {
    target: "bap.update"

    function refresh(): string { root.refresh(); return "refreshing" }
    function refreshCached(): string { root.refreshCached(); return "refreshing cached" }
    function probe(): string {
      return JSON.stringify({
        updatesError: root.updatesError,
        repoCount: root.updates.length,
        aurCount: root.aur.length,
        pacnewCount: root.pacnews.length,
        themeCount: root.themes.length,
        pluginCount: root.plugins.length,
        loading: root.loading,
        opened: root.opened
      })
    }
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "bap-update"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle { anchors.fill: parent; color: root.scrim }

    MouseArea { anchors.fill: parent; onClicked: root.dismiss() }

    BorderSurface {
      id: card
      width: root.cardWidth
      height: root.cardHeight
      radius: root.cornerRadius
      anchors.centerIn: parent
      color: root.background
      borderSpec: root.borderSpec
      padding: root.contentMargin

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          var step = Style.space(48)
          if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q) {
            root.dismiss()
            event.accepted = true
          } else if (event.key === Qt.Key_Down || event.key === Qt.Key_J) {
            flick.contentY = Math.min(flick.contentY + step, Math.max(0, flick.contentHeight - flick.height))
            event.accepted = true
          } else if (event.key === Qt.Key_Up || event.key === Qt.Key_K) {
            flick.contentY = Math.max(flick.contentY - step, 0)
            event.accepted = true
          } else if (event.key === Qt.Key_PageDown) {
            flick.contentY = Math.min(flick.contentY + flick.height, Math.max(0, flick.contentHeight - flick.height))
            event.accepted = true
          } else if (event.key === Qt.Key_PageUp) {
            flick.contentY = Math.max(flick.contentY - flick.height, 0)
            event.accepted = true
          } else if (event.key === Qt.Key_R) {
            root.refreshMode = "full"
            root.refresh()
            event.accepted = true
          } else if (event.key === Qt.Key_U) {
            root.runUpdate()
            event.accepted = true
          } else if (event.key === Qt.Key_T) {
            root.dismiss()
            Quickshell.execDetached(["omarchy-launch-floating-terminal-with-presentation", "omarchy-theme-update"])
            event.accepted = true
          } else if (event.key === Qt.Key_P) {
            root.dismiss()
            Quickshell.execDetached(["omarchy-launch-floating-terminal-with-presentation", "omarchy-plugin-update", "--yes"])
            event.accepted = true
          }
        }
      }

      Column {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: Style.spacing.md

        // ---- Header
        Column {
          width: parent.width
          spacing: Style.space(4)

          Row {
            width: parent.width
            spacing: Style.spacing.md

            Text {
              text: " Bap Update Sentry"
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.heading
              font.bold: true
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: root.loading ? "checking…" : ""
              color: root.foreground
              opacity: 0.55
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
            }
          }

          Text {
            width: parent.width
            text: root.summaryText()
            color: root.updatesError ? root.urgent : root.foreground
            opacity: root.updatesError ? 1 : 0.7
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            elide: Text.ElideRight
          }
        }

        Rectangle { width: parent.width; height: 1; color: root.borderColor; opacity: 0.5 }

        // ---- Scrollable body
        Flickable {
          id: flick
          width: parent.width
          height: parent.height - y - footer.height - Style.spacing.md
          contentWidth: width
          contentHeight: body.height
          clip: true
          boundsBehavior: Flickable.StopAtBounds

          Column {
            id: body
            width: flick.width
            spacing: Style.spacing.md

            // ---- Pending updates (repo)
            Text {
              text: "Pending Updates (" + root.updates.length + ")"
              color: root.foreground
              opacity: 0.55
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
            }

            Repeater {
              model: root.updates

              Row {
                required property var modelData
                width: body.width
                spacing: Style.spacing.md

                Text {
                  width: Style.space(180)
                  text: (modelData.risky ? "⚠ " : "") + modelData.name
                  color: modelData.risky ? root.urgent : root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.body
                  font.bold: modelData.risky === true
                  elide: Text.ElideRight
                }

                Text {
                  width: parent.width - Style.space(180) - parent.spacing
                  text: modelData.old + " → " + modelData.new
                  color: root.foreground
                  opacity: 0.65
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  elide: Text.ElideMiddle
                }
              }
            }

            Text {
              visible: root.updates.length === 0
              text: root.updatesError ? "Could not check for updates" : "Repo is up to date"
              color: root.foreground
              opacity: 0.5
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
            }

            Rectangle { width: body.width; height: 1; color: root.borderColor; opacity: 0.5 }

            // ---- AUR updates
            Text {
              text: "AUR Updates (" + root.aur.length + ")"
              color: root.foreground
              opacity: 0.55
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
            }

            Repeater {
              model: root.aur

              Row {
                required property var modelData
                width: body.width
                spacing: Style.spacing.md

                Text {
                  width: Style.space(180)
                  text: (modelData.risky ? "⚠ " : "") + modelData.name
                  color: modelData.risky ? root.urgent : root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.body
                  font.bold: modelData.risky === true
                  elide: Text.ElideRight
                }

                Text {
                  width: parent.width - Style.space(180) - parent.spacing
                  text: modelData.old + " → " + modelData.new
                  color: root.foreground
                  opacity: 0.65
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  elide: Text.ElideMiddle
                }
              }
            }

            Text {
              visible: root.aur.length === 0
              text: "No AUR updates"
              color: root.foreground
              opacity: 0.5
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
            }

            Rectangle { width: body.width; height: 1; color: root.borderColor; opacity: 0.5 }

            // ---- .pacnew files
            Text {
              text: ".pacnew / .pacsave (" + root.pacnews.length + ")"
              color: root.foreground
              opacity: 0.55
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
            }

            Repeater {
              model: root.pacnews

              Text {
                required property string modelData
                width: body.width
                text: modelData
                color: root.foreground
                opacity: 0.8
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                elide: Text.ElideMiddle
              }
            }

            Text {
              visible: root.pacnews.length === 0
              text: "No unmerged config files — nice."
              color: root.foreground
              opacity: 0.5
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
            }

            Rectangle { width: body.width; height: 1; color: root.borderColor; opacity: 0.5 }

            // ---- Theme updates (cloned git themes with new commits)
            Text {
              text: "Theme Updates (" + root.themes.length + ")"
              color: root.foreground
              opacity: 0.55
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
            }

            Repeater {
              model: root.themes

              Row {
                required property var modelData
                width: body.width
                spacing: Style.spacing.md

                Text {
                  text: "↑ " + modelData.name
                  color: root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.body
                  elide: Text.ElideRight
                  width: Style.space(180)
                }

                Text {
                  width: parent.width - Style.space(180) - parent.spacing
                  text: modelData.count + " new commit" + (modelData.count === 1 ? "" : "s")
                  color: root.foreground
                  opacity: 0.65
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  elide: Text.ElideMiddle
                }
              }
            }

            Text {
              visible: root.themes.length === 0
              text: "Themes up to date"
              color: root.foreground
              opacity: 0.5
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
            }

            Rectangle { width: body.width; height: 1; color: root.borderColor; opacity: 0.5 }

            // ---- Plugin updates (git-managed plugins with new remote commits)
            Text {
              text: "Plugin Updates (" + root.plugins.length + ")"
              color: root.foreground
              opacity: 0.55
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
            }

            Repeater {
              model: root.plugins

              Row {
                required property var modelData
                width: body.width
                spacing: Style.spacing.md

                Text {
                  text: "↑ " + modelData.name
                  color: root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.body
                  elide: Text.ElideRight
                  width: Style.space(180)
                }

                Text {
                  width: parent.width - Style.space(180) - parent.spacing
                  text: modelData.count + " new commit" + (modelData.count === 1 ? "" : "s")
                  color: root.foreground
                  opacity: 0.65
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  elide: Text.ElideMiddle
                }
              }
            }

            Text {
              visible: root.plugins.length === 0
              text: "Plugins up to date"
              color: root.foreground
              opacity: 0.5
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
            }
          }
        }

        // ---- Footer
        Text {
          id: footer
          width: parent.width
          text: "↑/↓ scroll   r refresh   u update now   t update themes   p update plugins   esc close"
          color: root.foreground
          opacity: 0.45
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          horizontalAlignment: Text.AlignHCenter
        }
      }
    }
  }
}
