import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

Row {
  id: root
  height: parent.height
  property var battery: UPower.displayDevice
  property bool charging: battery.state === UPowerDevice.Charging
  readonly property int level: Math.round(battery.percentage * 100)

  Text {
    text: {
      let tier = root.level >= 0.75 ? 4
      : root.level >= 0.50 ? 3
      : root.level >= 0.25 ? 2
      : 1

      let batteryIcon = {
        1: "",
        2: "",
        3: "",
        4: ""
      }
      return batteryIcon[tier]
    }
    // text: root.level + "%"
    color: "#58C706"
    font.pixelSize: 30
    font.family: "JetBrains Mono"
    verticalAlignment: Text.AlignVCenter
    anchors.verticalCenter: parent.verticalCenter
    height: 20
  }
}
