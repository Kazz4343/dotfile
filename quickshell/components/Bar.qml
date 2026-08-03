import Quickshell
import QtQuick
import QtQuick.Layouts

PanelWindow {
  id: panel
  required property var modelData
  property var targetScreen: modelData

  screen: targetScreen
  anchors {
    top: true
    left: true
    right: true
  }
  implicitHeight: 60
  color: "transparent"
  exclusiveZone: 0

  mask: Region {
    item: islandContainer
  }

  // --- Single source of truth for "should the popup be open" ---
  // Debounced so moving the cursor from the pill down into the popup
  // (crossing the gap between the two windows) doesn't close it mid-transit.
  Timer {
    id: closeTimer
    interval: 150
    onTriggered: dashboard.expanded = false
  }
  function requestOpen() {
    closeTimer.stop()
    dashboard.expanded = true
  }
  function requestClose() {
    closeTimer.restart()
  }

  Rectangle {
    id: islandContainer
    property bool isActive: false
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: 4
    opacity: isActive ? 1 : (dashboard.expanded ? 1 : 0)

    Behavior on opacity {
      NumberAnimation {
        duration: 180
      }
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true

      onEntered: {
        islandContainer.isActive = true
        panel.requestOpen()
      }
      onExited: {
        islandContainer.isActive = false
        panel.requestClose()
      }
    }

    DashboardPopup {
      id: dashboard
      anchor.window: panel
      anchor.rect.x: islandContainer.x - 80
      anchor.rect.y: islandContainer.height + 10

      // Keep the popup open while the cursor is on it, and let it
      // close (after the debounce) once the cursor actually leaves.
      onHoverEntered: panel.requestOpen()
      onHoverExited: panel.requestClose()
    }

    implicitWidth: contentLayout.implicitWidth + 32
    implicitHeight: contentLayout.implicitHeight + 17
    color: "#3f3c46"
    radius: 22

    // Inner layout holding your bar modules
    RowLayout {
      id: contentLayout
      anchors.centerIn: parent
      spacing: 10

      Clock {}
      Workspaces {}
      Network {}
      Battery {}
    }
  }
}