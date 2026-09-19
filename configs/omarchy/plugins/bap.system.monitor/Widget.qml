import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

BarWidget {
  id: root
  moduleName: "bap.system.monitor"

  readonly property int intervalMs: Math.max(250, Number(root.setting("intervalMs", 1000)) || 1000)
  readonly property string netInterface: String(root.setting("netInterface", "") || "").trim()

  property int cpuUsage: 0
  property int memUsage: 0
  property real downSpeed: 0

  readonly property color foreground: root.bar ? root.bar.barForeground : Color.foreground
  readonly property string family: root.bar ? root.bar.fontFamily : Style.font.family

  property FileView statFile: FileView { path: "/proc/stat";    preload: false; blockLoading: true; printErrors: false }
  property FileView memFile:  FileView { path: "/proc/meminfo"; preload: false; blockLoading: true; printErrors: false }
  property FileView netFile:  FileView { path: "/proc/net/dev"; preload: false; blockLoading: true; printErrors: false }

  function refresh() {
    statFile.reload()
    memFile.reload()
    netFile.reload()
    root.cpuUsage = Model.readCpuUsage(statFile.text())
    root.memUsage = Model.readMemUsage(memFile.text())
    root.downSpeed = Model.readNetDownload(netFile.text(), root.netInterface)
  }

  Timer {
    id: ticker
    interval: root.intervalMs
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  readonly property real contentWidth: row.implicitWidth + Style.space(10)
  readonly property real contentHeight: root.barSize

  implicitWidth: root.vertical ? contentHeight : contentWidth
  implicitHeight: root.vertical ? contentWidth : contentHeight

  Item {
    id: layout
    anchors.fill: parent

    Row {
      id: row
      anchors.centerIn: parent
      spacing: Style.space(14)
      rotation: root.vertical ? 90 : 0
      transformOrigin: Item.Center

      // CPU
      Row {
        spacing: Style.space(6)
        IconText {
          id: cpuIcon
          anchors.verticalCenter: parent.verticalCenter
          text: "planner_review"
          color: root.cpuUsage >= 80 ? Color.urgent : root.foreground
          font.pixelSize: Style.bar.iconFont + 2
          font.weight: Font.DemiBold
          fill: 1
          
          SequentialAnimation on opacity {
            running: root.cpuUsage >= 80
            loops: Animation.Infinite
            NumberAnimation { to: 0.3; duration: 500; easing.type: Easing.InOutQuad }
            NumberAnimation { to: 1.0; duration: 500; easing.type: Easing.InOutQuad }
          }
        }
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: String(root.cpuUsage).padStart(2, "0") + "%"
          color: root.cpuUsage >= 80 ? Color.urgent : root.foreground
          font.family: root.family
          font.pixelSize: Style.font.caption
          renderType: Text.NativeRendering
          
          SequentialAnimation on opacity {
            running: root.cpuUsage >= 80
            loops: Animation.Infinite
            NumberAnimation { to: 0.3; duration: 500; easing.type: Easing.InOutQuad }
            NumberAnimation { to: 1.0; duration: 500; easing.type: Easing.InOutQuad }
          }
        }
      }

      // MEM
      Row {
        spacing: Style.space(6)
        IconText {
          id: memIcon
          anchors.verticalCenter: parent.verticalCenter
          text: "memory"
          color: root.memUsage >= 80 ? Color.urgent : root.foreground
          font.pixelSize: Style.bar.iconFont + 2
          font.weight: Font.DemiBold
          fill: 1
          
          SequentialAnimation on opacity {
            running: root.memUsage >= 80
            loops: Animation.Infinite
            NumberAnimation { to: 0.3; duration: 500; easing.type: Easing.InOutQuad }
            NumberAnimation { to: 1.0; duration: 500; easing.type: Easing.InOutQuad }
          }
        }
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: String(root.memUsage).padStart(2, "0") + "%"
          color: root.memUsage >= 80 ? Color.urgent : root.foreground
          font.family: root.family
          font.pixelSize: Style.font.caption
          renderType: Text.NativeRendering
          
          SequentialAnimation on opacity {
            running: root.memUsage >= 80
            loops: Animation.Infinite
            NumberAnimation { to: 0.3; duration: 500; easing.type: Easing.InOutQuad }
            NumberAnimation { to: 1.0; duration: 500; easing.type: Easing.InOutQuad }
          }
        }
      }

      // NET
      Row {
        spacing: Style.space(6)
        IconText {
          anchors.verticalCenter: parent.verticalCenter
          text: "download"
          color: root.foreground
          font.pixelSize: Style.bar.iconFont + 2
          font.weight: Font.DemiBold
          
          fill: 1
        }
        // Fixed-width wrapper: keeps icon + number tight, but reserves a constant
        // box so the changing speed (1->2->3 KB/s) can't resize the bar.
        // Text is left-aligned inside, so it stays glued to the icon.
        // Width is measured from the widest realistic string ("9999 KB/s") via
        // TextMetrics, so the box is exactly tight — no extra gap to neighbors.
        Item {
          anchors.verticalCenter: parent.verticalCenter
          height: netText.height
          width: speedMetrics.width
          Text {
            id: netText
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            text: Model.formatSpeed(root.downSpeed)
            color: root.foreground
            font.family: root.family
            font.pixelSize: Style.font.caption
            renderType: Text.NativeRendering
          }
          TextMetrics {
            id: speedMetrics
            font.family: root.family
            font.pixelSize: Style.font.caption
            text: "9999 KB/s"
          }
        }
      }
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    keepSpace: true
    hasVisualContent: true
    labelVisible: false
    tooltipText: "CPU " + root.cpuUsage + "%  ·  RAM " + root.memUsage + "%  ·  " + Model.formatSpeed(root.downSpeed) + " down"
    onPressed: function(b) {
      if (b === Qt.LeftButton && root.bar) root.bar.run("omarchy-launch-or-focus-tui btop")
    }
  }
}
