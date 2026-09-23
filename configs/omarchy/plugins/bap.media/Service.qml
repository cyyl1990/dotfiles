pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import "CavaThemeModel.js" as CavaThemeModel

// One process-wide, lazy spectrum owner for every Shibumi output. Omarchy's
// official media service remains authoritative for player state and actions.
// This service owns only Cava availability, lifecycle, output, and theme data.
Item {
  id: root

  property string omarchyPath: ""
  property var shell: null
  property var manifest: null
  property bool runtimeWorkersEnabled: true
  property var spectrumClients: []
  property var levels: flatLevels(0.04)
  property var themeColors: []
  property string state: "inactive"
  property bool enableIpc: true
  property bool availabilityKnown: false
  property bool cavaAvailable: false
  property bool intentionalStop: false
  property bool probeCancelled: false
  property int failureCount: 0
  property int reviveAttempts: 0
  property int workerStartCount: 0
  property int lastExitCode: 0
  property string lastError: ""

  readonly property int bandCount: 24
  readonly property int clientCount: spectrumClients.length
  readonly property int maximumRetries: 3
  readonly property var mediaService: shell
    && typeof shell.firstPartyServiceFor === "function"
    ? shell.firstPartyServiceFor("omarchy.media") : null
  function findFallbackPlayer() {
    var players = Mpris.players ? Mpris.players.values : []
    for (var i = 0; i < players.length; i++) {
      if (players[i].playbackStatus === Mpris.Playing) return players[i]
    }
    return players.length > 0 ? players[0] : null
  }
  readonly property var activePlayer: mediaService
    ? mediaService.activePlayer : findFallbackPlayer()
  readonly property bool hasMedia: mediaService
    ? (mediaService.hasMedia !== undefined
        ? mediaService.hasMedia === true
        : (activePlayer !== null && (activePlayer.trackTitle || activePlayer.trackArtist || activePlayer.isPlaying === true)))
    : (activePlayer !== null && (activePlayer.trackTitle || activePlayer.trackArtist || activePlayer.playbackStatus === Mpris.Playing))
  readonly property bool active: hasMedia && activePlayer !== null
  readonly property bool playing: active && (mediaService
    ? activePlayer.isPlaying === true
    : activePlayer.playbackStatus === Mpris.Playing)
  readonly property bool spectrumWanted: runtimeWorkersEnabled
    && clientCount > 0 && playing
  readonly property bool workerRunning: cavaProcess.running
  readonly property bool probeRunning: cavaProbe.running
  readonly property string cavaThemePath: Quickshell.env("HOME")
    + "/.local/state/omarchy/current/theme/cava_theme"
  readonly property string themeNamePath: Quickshell.env("HOME")
    + "/.local/state/omarchy/current/theme.name"

  visible: false
  width: 0
  height: 0

  function flatLevels(value) {
    const result = []
    const level = Math.max(0, Math.min(1, Number(value) || 0))
    for (let index = 0; index < bandCount; index++) result.push(level)
    return result
  }

  function resetLevels() {
    levels = flatLevels(active ? 0.04 : 0.02)
  }

  function applyTheme(raw) {
    themeColors = CavaThemeModel.parse(raw)
  }

  function beginSpectrum(owner) {
    if (!owner || spectrumClients.indexOf(owner) >= 0) return false
    const next = spectrumClients.slice()
    next.push(owner)
    spectrumClients = next
    return true
  }

  function endSpectrum(owner) {
    if (!owner || spectrumClients.indexOf(owner) < 0) return false
    spectrumClients = spectrumClients.filter(function(candidate) {
      return candidate !== owner
    })
    return true
  }

  function spectrumConfig() {
    return [
      "[general]",
      "bars = 24",
      "framerate = 60",
      "autosens = 1",
      "sleep_timer = 0",
      "[input]",
      "method = pipewire",
      "source = auto",
      "[output]",
      "method = raw",
      "raw_target = /dev/stdout",
      "data_format = ascii",
      "ascii_max_range = 100",
      "[smoothing]",
      "monstercat = 0",
      "waves = 0",
      "noise_reduction = 20",
      ""
    ].join("\n")
  }

  function diagnosticStatus() {
    return {
      active: active,
      available: cavaAvailable,
      availabilityKnown: availabilityKnown,
      bandCount: bandCount,
      clientCount: clientCount,
      failureCount: failureCount,
      lastError: lastError,
      lastExitCode: lastExitCode,
      playing: playing,
      probeRunning: probeRunning,
      startCount: workerStartCount,
      state: state,
      workerRunning: workerRunning
    }
  }

  function applySpectrumLine(raw) {
    if (!spectrumWanted || !cavaProcess.running) return
    const line = String(raw || "")
    if (line.length === 0 || line.length > 4096) return
    const fields = line.split(";")
    const result = []
    for (let index = 0; index < bandCount; index++) {
      const parsed = parseInt(fields[index], 10)
      result.push(isNaN(parsed)
        ? 0 : Math.max(0, Math.min(1, parsed / 100)))
    }
    levels = result
  }

  function startCava() {
    if (!spectrumWanted || intentionalStop || cavaProcess.running
        || failureCount >= maximumRetries) return
    // Reset stdin pipe before each spawn so a previous run's leftover
    // buffering doesn't cause the new process to consume its own config
    // silently. The Process element keeps `stdinEnabled` sticky once
    // switched off, so rearming here is required for the multi-revive path.
    cavaProcess.stdinEnabled = true
    state = "starting"
    cavaProcess.running = true
  }

  function stopWorkers() {
    retryTimer.stop()
    failureCount = 0
    if (cavaProbe.running) {
      probeCancelled = true
      cavaProbe.running = false
    }
    if (cavaProcess.running) {
      intentionalStop = true
      cavaProcess.running = false
    }
    state = "inactive"
    resetLevels()
  }

  function scheduleRetry() {
    if (!spectrumWanted || failureCount >= maximumRetries) {
      state = "failed"
      return
    }
    retryTimer.interval = Math.min(8000,
      500 * Math.pow(2, Math.max(0, failureCount - 1)))
    state = "failed"
    retryTimer.restart()
  }

  function syncSpectrum() {
    if (!spectrumWanted) {
      stopWorkers()
      return
    }
    if (intentionalStop || cavaProcess.running || cavaProbe.running
        || retryTimer.running) return
    if (!availabilityKnown) {
      state = "probing"
      probeCancelled = false
      cavaProbe.running = true
      return
    }
    if (!cavaAvailable) {
      state = "unavailable"
      resetLevels()
      return
    }
    startCava()
  }

  onSpectrumWantedChanged: {
    if (spectrumWanted) reviveAttempts = 0
    syncSpectrum()
  }
  onClientCountChanged: {
    if (clientCount === 0) {
      availabilityKnown = false
      cavaAvailable = false
      failureCount = 0
      themeColors = []
    }
  }
  Component.onCompleted: resetLevels()
  Component.onDestruction: stopWorkers()

  Timer {
    id: retryTimer
    repeat: false
    onTriggered: root.syncSpectrum()
  }

  // Self-heal: cava can be killed externally (SIGTERM, e.g. when the bar
  // re-creates its service shim). Those exits still count as failures, so the
  // fast retry budget can run out while music keeps playing and the service
  // would stay latched in "failed" — flat bars until playback stops. Keep
  // upstream's bounded fast retries, then revive slowly (15s -> 60s) for as
  // long as the spectrum is still wanted; a new playback session resets the
  // slow budget.
  Timer {
    id: reviveTimer
    interval: root.reviveAttempts >= 3 ? 60000 : 15000
    repeat: true
    running: root.spectrumWanted && root.state === "failed"
    onTriggered: {
      if (!root.spectrumWanted || cavaProcess.running
          || cavaProbe.running || retryTimer.running) return
      root.reviveAttempts++
      root.failureCount = 0
      root.syncSpectrum()
    }
  }

  Process {
    id: cavaProbe
    command: ["sh", "-c", "command -v cava >/dev/null 2>&1"]
    onExited: function(exitCode) {
      if (root.probeCancelled) {
        root.probeCancelled = false
        root.availabilityKnown = false
        if (root.spectrumWanted)
          Qt.callLater(function() { root.syncSpectrum() })
        return
      }
      root.availabilityKnown = true
      root.cavaAvailable = exitCode === 0
      if (!root.spectrumWanted) {
        root.state = "inactive"
        return
      }
      if (!root.cavaAvailable) {
        root.state = "unavailable"
        root.resetLevels()
        return
      }
      root.startCava()
    }
  }

  Process {
    id: cavaProcess
    command: ["cava", "-p", "/dev/stdin"]
    stdinEnabled: true
    onStarted: {
      root.workerStartCount++
      root.lastError = ""
      root.state = "running"
      write(root.spectrumConfig())
      stdinEnabled = false
    }
    stdout: SplitParser {
      splitMarker: "\n"
      onRead: function(line) { root.applySpectrumLine(line) }
    }
    stderr: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.lastError = String(text || "").trim().slice(0, 512)
      }
    }
    onExited: function(exitCode) {
      root.lastExitCode = Number(exitCode)
      const stoppedByOwner = root.intentionalStop
      root.intentionalStop = false
      root.resetLevels()
      if (stoppedByOwner) {
        root.state = "inactive"
        if (root.spectrumWanted)
          Qt.callLater(function() { root.syncSpectrum() })
        return
      }
      if (!root.spectrumWanted) {
        root.state = "inactive"
        return
      }
      root.failureCount++
      root.scheduleRetry()
    }
  }

  Loader {
    active: root.enableIpc
    sourceComponent: Component {
      IpcHandler {
        target: "shibumi-media-spectrum"

        function status(): string {
          return JSON.stringify(root.diagnosticStatus())
        }
      }
    }
  }

  Loader {
    active: root.clientCount > 0
    sourceComponent: Component {
      Item {
        FileView {
          id: themeNameFile
          path: root.themeNamePath
          watchChanges: true
          printErrors: false
          onFileChanged: reload()
          onLoaded: cavaThemeFile.reload()
        }

        FileView {
          id: cavaThemeFile
          path: root.cavaThemePath
          watchChanges: true
          printErrors: false
          onFileChanged: reload()
          onLoaded: root.applyTheme(text())
          onLoadFailed: root.applyTheme("")
        }
      }
    }
  }
}
