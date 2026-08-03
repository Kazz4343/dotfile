import Quickshell
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts

Row {
  id: root
  Layout.alignment: Qt.AlignVCenter
  property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
  property var active: wifiDevice ? wifiDevice.networks.values.find(n => n.connected) : null

  readonly property real signal : active ? active.signalStrength : 0

  readonly property string icon: {
    if (!Networking.wifiEnabled ) return ""
    if (!active ) return "󱚼"

    let tier = signal >= 0.75 ? 4
             : signal >= 0.50 ? 3
             : signal >= 0.25 ? 2
             : 1

    let tierIcons = {
        1: "󰤟",
        2: "󰤢",
        3: "󰤥",
        4: "󰤨"
    }

    return tierIcons[tier]  
  }

  Text {
    id:textIcon
    text: root.icon
    color: Networking.wifiEnabled ? "#FFAD5C" : "#FFAD5C"
    font.family: "JetBrains Mono"
    font.pixelSize: 25
    verticalAlignment: Text.AlignVCenter
    anchors.verticalCenter: parent.verticalCenter
    height: 20
  }

}
