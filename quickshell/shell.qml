import Quickshell
import QtQuick
import Quickshell.Hyprland
import QtQuick.Layouts
import "./components"

ShellRoot {
    Variants {
        model: Quickshell.screens
        Bar {}
    }
    OsdVolume {}
    ReloadPopup {}
    PopupWorkspaces {}
}
