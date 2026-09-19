pragma ComponentBehavior: Bound

import QtQuick

Item {
  id: root

  property var levels: []
  property color tint: "white"
  property var themeColors: []
  property bool playing: false
  readonly property int bandCount: 24
  readonly property int renderedBandCount: bandCount

  function barColor(index) {
    const palette = root.themeColors || []
    if (!palette || palette.length === 0) return root.tint
    if (palette.length === 1) return palette[0]
    const ratio = index / Math.max(1, root.bandCount - 1)
    const scaled = ratio * (palette.length - 1)
    const idx = Math.min(palette.length - 2, Math.floor(scaled))
    const frac = scaled - idx
    const c1 = Qt.color(palette[idx])
    const c2 = Qt.color(palette[idx + 1])
    return Qt.rgba(
      c1.r + (c2.r - c1.r) * frac,
      c1.g + (c2.g - c1.g) * frac,
      c1.b + (c2.b - c1.b) * frac,
      1.0
    )
  }

  implicitWidth: 144
  implicitHeight: 28
  width: implicitWidth
  height: implicitHeight

  Row {
    anchors.centerIn: parent
    spacing: 7

    Item {
      id: vinylMark
      width: 18
      height: 18
      anchors.verticalCenter: parent.verticalCenter
      transformOrigin: Item.Center

      Canvas {
        anchors.fill: parent
        antialiasing: true
        property color canvasTint: root.tint
        onCanvasTintChanged: requestPaint()
        onPaint: {
          const ctx = getContext("2d")
          ctx.clearRect(0, 0, width, height)
          ctx.strokeStyle = canvasTint
          ctx.fillStyle = canvasTint
          ctx.lineWidth = 1.4

          ctx.beginPath()
          ctx.arc(width / 2, height / 2, 7.2, 0, Math.PI * 2)
          ctx.stroke()
          ctx.globalAlpha = 0.55
          ctx.beginPath()
          ctx.arc(width / 2, height / 2, 4.6, -0.35, 2.35)
          ctx.stroke()
          ctx.beginPath()
          ctx.arc(width / 2, height / 2, 4.6, 2.8, 5.5)
          ctx.stroke()
          ctx.globalAlpha = 1
          ctx.beginPath()
          ctx.arc(width / 2, height / 2, 1.45, 0, Math.PI * 2)
          ctx.fill()
        }
        Component.onCompleted: requestPaint()
      }

      NumberAnimation on rotation {
        from: 0
        to: 360
        duration: 3200
        loops: Animation.Infinite
        running: root.visible && root.playing
      }
    }

    Item {
      width: 96
      height: 22
      anchors.verticalCenter: parent.verticalCenter

      Repeater {
        model: root.bandCount

        Rectangle {
          required property int index
          readonly property real level: {
            const values = root.levels || []
            return values[index] === undefined
              ? 0.04 : Math.max(0, Math.min(1, Number(values[index]) || 0))
          }
          readonly property real halfHeight: 1 + level * 9

          x: index * ((96 - 2) / (root.bandCount - 1))
          anchors.verticalCenter: parent.verticalCenter
          width: 2
          height: halfHeight * 2
          radius: 1
          color: root.barColor(index)
          antialiasing: true
        }
      }
    }

    Item {
      width: 16
      height: 18
      anchors.verticalCenter: parent.verticalCenter

      Row {
        anchors.centerIn: parent
        spacing: 3
        visible: root.playing

        Repeater {
          model: 2
          Rectangle {
            required property int index
            width: 3
            height: 10
            radius: 1
            color: root.tint
          }
        }
      }

      Canvas {
        anchors.centerIn: parent
        width: 11
        height: 12
        visible: !root.playing
        antialiasing: true
        property color canvasTint: root.tint
        onCanvasTintChanged: requestPaint()
        onPaint: {
          const ctx = getContext("2d")
          ctx.clearRect(0, 0, width, height)
          ctx.fillStyle = canvasTint
          ctx.beginPath()
          ctx.moveTo(2, 1)
          ctx.lineTo(width - 1, height / 2)
          ctx.lineTo(2, height - 1)
          ctx.closePath()
          ctx.fill()
        }
        Component.onCompleted: requestPaint()
      }
    }
  }
}
