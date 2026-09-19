import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Bar side of Bap Update Sentry: total pending updates (repo + AUR) shown as
// a small red badge on the package icon. Hidden entirely when nothing is pending.
BarWidget {
  id: root
  moduleName: "bap.update"

  readonly property string helperPath: Qt.resolvedUrl("sentry-check.py").toString().replace("file://", "")

  property int repoCount: 0
  property int aurCount: 0
  property int riskyCount: 0
  property int pacnewCount: 0
  property int themeCount: 0
  property int pluginCount: 0
  property bool checkError: false

  // Total pending = repo + AUR + theme clones + git plugins with new commits.
  readonly property int totalCount: root.repoCount + root.aurCount + root.themeCount + root.pluginCount

  readonly property bool attention: riskyCount > 0 || root.pacnewCount > 0 || root.themeCount > 0 || root.pluginCount > 0
  readonly property string icon: "\uf487" // nf-oct-package

  function refresh() {
    if (!fullProc.running) fullProc.running = true
  }

  function refreshCached() {
    if (!fullProc.running && !cachedProc.running) cachedProc.running = true
  }

  function apply(text) {
    try {
      var s = JSON.parse(text)
      var updates = s.updates || []
      var aur = s.aur || []
      root.repoCount = updates.length
      root.aurCount = aur.length
      var risky = 0
      for (var i = 0; i < updates.length; i++) if (updates[i].risky) risky++
      for (var j = 0; j < aur.length; j++) if (aur[j].risky) risky++
      root.riskyCount = risky
      root.pacnewCount = (s.pacnew || []).length
      root.themeCount = (s.themes || []).length
      root.pluginCount = (s.plugins || []).length
      root.checkError = s.updatesError === true
    } catch (e) {
      console.warn("bap.update: bad state json: " + e)
    }
  }

  function summon() {
    if (root.bar) root.bar.run("omarchy-shell shell summon bap.update '{}'")
  }

  function tooltip() {
    var parts = []
    if (root.checkError) {
      parts.push("update check failed")
    } else {
      parts.push(root.repoCount + " repo update" + (root.repoCount === 1 ? "" : "s"))
      if (root.aurCount > 0) parts.push(root.aurCount + " AUR update" + (root.aurCount === 1 ? "" : "s"))
    }
    if (root.riskyCount > 0) parts.push(root.riskyCount + " risky")
    if (root.pacnewCount > 0) parts.push(root.pacnewCount + " .pacnew")
    if (root.themeCount > 0) parts.push(root.themeCount + " theme update" + (root.themeCount === 1 ? "" : "s"))
    if (root.pluginCount > 0) parts.push(root.pluginCount + " plugin update" + (root.pluginCount === 1 ? "" : "s"))
    return "Bap Update Sentry — " + parts.join(" • ")
  }

  // Hide the whole widget when there is nothing to report.
  visible: root.totalCount > 0 || root.checkError
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Process {
    id: fullProc
    command: ["python3", root.helperPath, "full"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.apply(text)
    }
  }

  Process {
    id: cachedProc
    command: ["python3", root.helperPath, "cached"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.apply(text)
    }
  }

  // Full check (network) every 30 minutes.
  Timer {
    interval: 1800000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  // Cheap cache re-read so overlay actions (refresh) show up in the bar.
  Timer {
    interval: 60000
    running: true
    repeat: true
    onTriggered: root.refreshCached()
  }

  IpcHandler {
    target: "bap.update"

    function refresh(): void { root.broadcast("refresh") }
    function refreshCached(): void { root.broadcast("refreshCached") }
    function probe(): string {
      return JSON.stringify({
        repoCount: root.repoCount,
        aurCount: root.aurCount,
        riskyCount: root.riskyCount,
        pacnewCount: root.pacnewCount,
        themeCount: root.themeCount,
        pluginCount: root.pluginCount,
        totalCount: root.totalCount,
        checkError: root.checkError,
        attention: root.attention
      })
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    fixedWidth: root.vertical ? (root.bar ? root.bar.barSize : 32) : -1
    fixedHeight: root.vertical ? (root.bar ? root.bar.barSize : 32) : -1
    foreground: root.bar ? root.bar.foreground : Color.foreground
    text: root.icon
    active: root.attention
    useActiveColor: false
    tooltipText: root.tooltip()
    onPressed: root.summon()

    // Bump icon size past the theme default (BarIconButton locks fontSize to
    // Style.bar.iconFont via a binding; assigning after completion overrides it).
    Component.onCompleted: button.fontSize = Math.round(Style.bar.iconFont * 1.05)

    // Small red count badge sitting in the top-right corner of the icon.
    Rectangle {
      id: badge
      visible: root.totalCount > 0
      anchors.top: parent.top
      anchors.right: parent.right
      anchors.topMargin: Style.space(1)
      anchors.rightMargin: Style.space(1)
      width: Math.max(Style.space(11), badgeText.implicitWidth + Style.space(2))
      height: width
      radius: width / 2
      color: "#e5484d"
      border.width: Style.space(1)
      border.color: root.bar ? root.bar.background : "#000000"

      Text {
        id: badgeText
        anchors.centerIn: parent
        text: root.totalCount > 99 ? "99+" : String(root.totalCount)
        color: "#ffffff"
        font.family: Style.font.family
        font.pixelSize: Style.space(8)
        font.bold: true
      }
    }
  }
}
