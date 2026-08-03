import QtQuick
import QtQuick.Layouts
import Quickshell

Row {

  width: clockText.implicitWidth + 14
  height: 22
  Layout.alignment: Qt.AlignVCenter
  Text {
    id: clockText
    text: Qt.formatDateTime(new Date(), "HH:mm")
    color: "#A4A1B5"
    font.family: "JetBrains Mono"
    font.pixelSize: 17
    font.bold: true

    Timer {
      interval: 1000
      running: true
      repeat: true
      onTriggered: clockText.text = Qt.formatDateTime(new Date(), "HH:mm")
    }
  }
}
