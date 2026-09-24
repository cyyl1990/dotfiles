import QtQuick
import QtPositioning

Item {
  id: root
  signal located(var location)
  signal failed(string message)
  property bool requesting: false

  function request() {
    if (!source.valid) {
      failed("Không có nguồn vị trí thiết bị. Hãy dùng mã ZIP hoặc dán vĩ độ, kinh độ.")
      return
    }
    requesting = true
    deadline.restart()
    source.update(20000)
  }

  function cancel() {
    requesting = false
    deadline.stop()
    source.stop()
  }

  PositionSource {
    id: source
    active: false
    onPositionChanged: {
      if (!root.requesting || !position.latitudeValid || !position.longitudeValid) return
      var coordinate = position.coordinate
      var accuracy = position.horizontalAccuracyValid
        ? "Độ chính xác: khoảng " + Math.round(position.horizontalAccuracy) + " m" : "Không báo độ chính xác"
      root.cancel()
      root.located({
        name: "Vị trí thiết bị",
        description: accuracy + " (có thể dựa trên mạng, không phải GPS)",
        latitude: coordinate.latitude,
        longitude: coordinate.longitude
      })
    }
    onSourceErrorChanged: {
      if (!root.requesting || sourceError === PositionSource.NoError) return
      root.cancel()
      root.failed("Vị trí thiết bị không khả dụng hoặc bị từ chối quyền. Hãy dùng mã ZIP hoặc toạ độ.")
    }
  }

  Timer {
    id: deadline
    interval: 21000
    onTriggered: {
      root.cancel()
      root.failed("Lấy vị trí thiết bị quá thời gian. Hãy dùng mã ZIP hoặc toạ độ.")
    }
  }
}
