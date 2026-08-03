import QtQuick
import Quickshell
import Quickshell.Hyprland

Scope {
    id: root

    // Automatically updates whenever the focused workspace changes
    property int currentWorkspace: Hyprland.focusedWorkspace?.id ?? 0

    property bool isActive: false

    onCurrentWorkspaceChanged: {
        if (currentWorkspace === 0)
            return;

        isActive = true;
        hideTimer.restart();
    }

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: root.isActive = false
    }

    PanelWindow {
        visible: root.isActive

        anchors {
            top: true
            left: true
        }

        margins {
            top: 5
            left: 5
        }

        exclusiveZone: 0
        implicitWidth: 50
        implicitHeight: 50
        color: "transparent"

        mask: Region {}

        Rectangle {
            anchors.fill: parent
            radius: 22
            color: "#3f3c46"

            Text {
                anchors.centerIn: parent
                text: root.currentWorkspace

                font.pixelSize: 26
                font.bold: true
                color: "white"
            }
        }
    }
}
