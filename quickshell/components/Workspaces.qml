import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

  Row {
    spacing: 1
    
    
    Repeater {
      model: 7
      id: dot

      Rectangle {
        property bool isActive: Hyprland.focusedWorkspace?.id === (index +1)
        
        implicitWidth: textContent.implicitWidth+30
        implicitHeight: 22
        radius: 24
        color: isActive ? "#ffad5c" : "#3f3c46"

        Text {
          id:textContent
          anchors.centerIn: parent
          text: index + 1
          font.pixelSize: 17
          font.family: "JetBrains Mono"
          color: isActive? "#000000" : "#a4a1b5"
          font.bold: true
        }

        Behavior on color {
          ColorAnimation { duration: 200}
        }
      }
    
    }
  }
