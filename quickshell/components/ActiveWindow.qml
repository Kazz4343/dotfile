import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Item {
  id: root
  property string activeWindow: "Window"
  anchors.verticalCenter: parent.verticalCenter
  anchors.leftMargin: 180
  anchors.left: parent.left
  implicitWidth: textItem.implicitWidth
  implicitHeight: textItem.implicitHeight

    readonly property string currentAppId: Hyprland.activeToplevel?.wayland?.appId ?? "Window"

    // 2. Trigger an animation cycle whenever currentAppId changes
    onCurrentAppIdChanged: {
        textFadeAnimation.restart()
    }

      Text {
        id: textItem
        // 1. Tell QML to parse this as Rich Text
        textFormat: Text.RichText
    
        // 2. Use a dynamic javascript expression to build your HTML string safely
        text: {
            // Fallback to "Window" if appId is null or undefined
            let appId = Hyprland.activeToplevel?.wayland?.appId ?? "Window";
            
            // Wrap brackets in a specific hex color code (e.g., Pink/Magenta #ff79c6)
            return "<font color='#ec275f'>[</font> " + appId + " <font color='#ec275f'>]</font>";
    }
        // text: "[ " + Hyprland.activeToplevel?.wayland?.appId + " ]" ?? "Window"
        color: '#e6e6e7'
        font.pixelSize: 15
        elide: Text.ElideRight
        clip: true
        font.family: "Press Start 2P"
        font.bold: true
        maximumLineCount: 1
      }
      QtObject {
        id: internal
        property string visibleText: "Window"
    }

    // 3. The Sequential Animation Sequence
    SequentialAnimation {
        id: textFadeAnimation
        
        // Step A: Fade old text out
        NumberAnimation { 
            target: textItem
            property: "opacity"
            to: 0
            duration: 0 // milliseconds
            easing.type: Easing.OutQuad
        }
        
        // Step B: Swap the text string while it's completely invisible
        PropertyAction { 
            target: internal
            property: "visibleText"
            value: root.currentAppId 
        }
        
        // Step C: Fade new text in
        NumberAnimation { 
            target: textItem
            property: "opacity"
            to: 1
            duration: 200
            easing.type: Easing.InQuad
        }
    }
}