import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

BarWidget {
  id: root
  moduleName: "bap.netmon"

  readonly property string displayText: _downSpeed + " \u2193  " + _upSpeed + " \u2191"

  property string _downSpeed: "—"
  property string _upSpeed: "—"
  property int _prevRx: 0
  property int _prevTx: 0
  // Dùng _procTime riêng thay vì _prevTime để tránh race giữa
  // Timer (ghi _prevTime khi trigger) và Process.onOutputChanged
  // (đọc timestamp để tính delta).
  property int _procTime: 0

  IpcHandler {
    target: "bap.netmon"
    function probe(): string {
      return JSON.stringify({down: _downSpeed, up: _upSpeed})
    }
    function refresh(): void { _readStats(true) }
  }

  function _readStats(force) {
    if (proc.running || (!force && _procTime === 0)) return
    proc.start()
  }

  Process {
    id: proc
    program: Qt.resolvedUrl("netmon_helper.py")
    stdoutMode: Process.Line
    onOutputChanged: {
      var line = proc.readLine()
      if (!line) return
      var parts = line.split(":")
      if (parts.length < 2) return
      var rx = parseInt(parts[0]) || 0
      var tx = parseInt(parts[1]) || 0
      var now = Date.now()

      if (_procTime > 0) {
        var dt = (now - _procTime) / 1000.0
        if (dt > 0) {
          var rxb = (rx - _prevRx) / dt
          var txb = (tx - _prevTx) / dt
          _downSpeed = _formatSpeed(rxb)
          _upSpeed = _formatSpeed(txb)
        }
      }

      _prevRx = rx
      _prevTx = tx
      _procTime = now
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: _readStats(false)
  }

  // Reset state khi bar thay đổi (widget bị unload/reload).
  onBarChanged: {
    _downSpeed = "—"
    _upSpeed = "—"
    _prevRx = 0
    _prevTx = 0
    _procTime = 0
  }

  function _formatSpeed(bytesPerSec) {
    if (bytesPerSec < 0) return "—"
    if (bytesPerSec < 1024) return Math.round(bytesPerSec) + " B/s"
    if (bytesPerSec < 1048576) return Math.round(bytesPerSec / 1024) + " K/s"
    return Math.round(bytesPerSec / 1048576 * 10) / 10 + " M/s"
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    fontSize: qs.Ui.Style.font.bodySmall
    anchors.fill: parent
    bar: root.bar
    text: displayText
    labelVisible: true
    onPressed: function(b) {
      if (b === Qt.RightButton) {
        if (root.bar) root.bar.run("nm-connection-editor")
      }
    }
  }
}
