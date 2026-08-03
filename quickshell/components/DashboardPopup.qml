import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Networking

PopupWindow {
    id: root

    implicitWidth: 590
    implicitHeight: 500
    color: "transparent"
    
    property bool expanded: false
    visible: expanded

    // Emitted so the bar can keep the popup open while the cursor is
    // physically over it (fixes it closing mid-transit from the bar).
    signal hoverEntered()
    signal hoverExited()

    // --- State Properties ---
    property var battery: UPower.displayDevice
    property bool charging: battery.state === UPowerDeviceState.Charging || 
                            battery.state === UPowerDeviceState.FullyCharged
    readonly property int level: Math.round(battery.percentage * 100)

    property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
    property var active: wifiDevice ? wifiDevice.networks.values.find(n => n.connected) : null
    readonly property real signal: active ? active.signalStrength : 0

    // --- Calendar State ---
    // A single "now" that ticks once a minute so the calendar and header
    // stay in sync without recreating Date() objects all over the place.
    property date now: new Date()
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    property int calYear: now.getFullYear()
    property int calMonth: now.getMonth() // 0-11, allows paging without touching "now"
    readonly property int todayDate: now.getDate()
    readonly property int todayMonth: now.getMonth()
    readonly property int todayYear: now.getFullYear()

    // Days in the currently displayed month
    readonly property int daysInMonth: new Date(calYear, calMonth + 1, 0).getDate()
    // Day-of-week (0=Sun..6=Sat) that day 1 falls on
    readonly property int firstDayOffset: new Date(calYear, calMonth, 1).getDay()

    function goPrevMonth() {
        if (calMonth === 0) { calMonth = 11; calYear -= 1 }
        else { calMonth -= 1 }
    }
    function goNextMonth() {
        if (calMonth === 11) { calMonth = 0; calYear += 1 }
        else { calMonth += 1 }
    }

    // --- Main Window Background ---
    Rectangle {
        anchors.fill: parent

        opacity: root.expanded ? 1 : 0
        scale: root.expanded ? 1.0 : 0.95
        y: root.expanded ? 0 : -300

        transformOrigin: Item.Top

        Behavior on opacity {
          NumberAnimation {
            duration: 180
          }
        }

        Behavior on scale {
          NumberAnimation {
            duration: 220
            easing.type: Easing.OutBack
          }
        }

        Behavior on y {
          NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
          }
        }

        radius: 24
        color: "#252430"
        border.color: "#3f3c46"
        border.width: 1

        // Hover-only: tracks cursor presence without swallowing clicks,
        // so it can't interfere with the calendar buttons underneath.
        HoverHandler {
            onHoveredChanged: hovered ? root.hoverEntered() : root.hoverExited()
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            // ==========================================
            // LEFT SIDE: CALENDAR
            // ==========================================
            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: 312
                radius: 20
                color: "#2d2b38"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    // --- Month header with prev/next controls ---
                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            text: "‹"
                            color: "#a4a1b5"
                            font.pixelSize: 22
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -6
                                onClicked: root.goPrevMonth()
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text: Qt.formatDate(new Date(root.calYear, root.calMonth, 1), "MMMM yyyy")
                            color: "#e6e6e7"
                            font.pixelSize: 24
                        }

                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            text: "›"
                            color: "#a4a1b5"
                            font.pixelSize: 22
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -6
                                onClicked: root.goNextMonth()
                            }
                        }
                    }

                    // --- Weekday labels (Sun..Sat, matches JS getDay()) ---
                    GridLayout {
                        columns: 7
                        Layout.fillWidth: true

                        Repeater {
                            model: ["S", "M", "T", "W", "T", "F", "S"]
                            Text {
                                Layout.preferredWidth: 36
                                horizontalAlignment: Text.AlignHCenter
                                text: modelData
                                color: "#6f6c7a"
                                font.pixelSize: 13
                                font.bold: true
                            }
                        }
                    }

                    // --- Day grid: 6 weeks x 7 days is always enough to fit any month ---
                    GridLayout {
                        columns: 7

                        Repeater {
                            model: 42

                            Item {
                                implicitWidth: 36
                                implicitHeight: 36

                                // Day number this cell represents, accounting for the
                                // offset of the 1st and the previous month's spillover.
                                readonly property int dayNum: index - root.firstDayOffset + 1
                                readonly property bool inMonth: dayNum >= 1 && dayNum <= root.daysInMonth
                                readonly property bool isToday: inMonth &&
                                    dayNum === root.todayDate &&
                                    root.calMonth === root.todayMonth &&
                                    root.calYear === root.todayYear

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 18
                                    color: parent.isToday ? "#ffb458" : "transparent"
                                    visible: parent.inMonth

                                    Text {
                                        anchors.centerIn: parent
                                        text: parent.parent.dayNum
                                        color: parent.parent.isToday ? "#000000" : "#A4A1B5"
                                        font.pixelSize: 14
                                    }
                                }
                            }
                        }
                    }

                RowLayout {
                  implicitHeight: 70
                  implicitWidth: 290
                  Rectangle {
                    anchors.fill: parent
                    color: "#ffb458"
                    radius: 40

                    Text {
                      id: calendarText
                      anchors.centerIn: parent
                      color: "#000000"
                      text: Qt.formatDateTime(new Date(), "hh:mm | dddd,  MMMM  d,  yyyy")

                      Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: calendarText.text = Qt.formatDateTime(new Date(), "hh:mm | dddd,  MMMM  d,  yyyy")
    }
                    }
                  }
                }
              }
            }

            // ==========================================
            // RIGHT SIDE: SYSTEM WIDGETS
            // ==========================================
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 15

                // --- Wi-Fi Status Widget ---
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    radius: 18
                    color: "#2d2b38"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 10

                        // Info Group (Left)
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            spacing: 4

                            RowLayout {
                                spacing: 8

                                Text {
                                    text: "󰖩"
                                    color: "#a4a1b5"
                                    font.pixelSize: 22
                                }

                                Text {
                                    text: "Wi-Fi"
                                    color: "#a4a1b5"
                                    font.pixelSize: 18
                                    font.bold: true
                                }
                            }

                            Text {
                                text: {
                                    if (active) return root.active.name
                                    return "Disconnected"
                                }
                                color: active ? "#58c706" : "red"
                                font.pixelSize: 16
                                font.bold: true
                            }
                        }

                        // Signal Bars Group (Right)
                        ColumnLayout {
                            Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                            spacing: 4

                            Text {
                                Layout.alignment: Qt.AlignRight
                                text: "󰣸"
                                color: "#58c706"
                                font.pixelSize: 22
                            }

                            Text {
                                Layout.alignment: Qt.AlignRight
                                text: Math.round(root.signal * 100) + "%"
                                color: "#a4a1b5"
                                font.pixelSize: 20
                            }
                        }
                    }
                }

                // --- Battery Widget ---
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 140
                    radius: 18
                    color: "#2d2b38"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 10

                        // Left Side: Vertical Stack for Battery Details
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            spacing: 6

                            // 1. Header Row
                            RowLayout {
                                spacing: 8

                                Text {
                                    text: "󱐋"
                                    color: "#a4a1b5"
                                    font.pixelSize: 22
                                }

                                Text {
                                    text: "Battery"
                                    color: "#a4a1b5"
                                    font.pixelSize: 16
                                    font.bold: true
                                }
                            }

                            // 2. Large Percentage Display
                            Text {
                                text: root.level + "%"
                                color: "#58c706"
                                font.pixelSize: 34
                                font.bold: true
                            }

                            // 3. Status and Time Remaining
                            Text {
                                color: "#a4a1b5"
                                font.pixelSize: 14
                                text: root.charging ? "Plugin" : "Unplug"
                            }
                        }

                        // Right Side: Large Dynamic Battery Icon
                        ColumnLayout {
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                            Text {
                                color: "#58c706"
                                font.pixelSize: 60
                                text: {
                                    if (root.charging) return "󰂄";
                                    if (root.level >= 90) return "󰁹";
                                    if (root.level >= 70) return "󰂁";
                                    if (root.level >= 50) return "󰁿";
                                    if (root.level >= 30) return "󰁽";
                                    return "󰁻";
                                }
                            }
                        }
                    }
                }

                // --- System Resources Widget ---
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 18
                    color: "#2d2b38"

                    // The data source: polls /proc + df every 2s.
                    // See SystemStats.qml if you want to change the interval
                    // or add more metrics (e.g. per-core, network throughput).
                    SystemStats {
                        id: sysStats
                    }

                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 14

                        // --- CPU ---
                        Column {
                            width: parent.width
                            spacing: 4

                            Text {
                                text: "CPU: " + sysStats.cpuPercent + "%"
                                color: "#e6e6e7"
                            }

                            Rectangle {
                                width: parent.width
                                height: 6
                                radius: 3
                                color: "#3f3c46"

                                Rectangle {
                                    width: parent.width * (sysStats.cpuPercent / 100)
                                    height: parent.height
                                    radius: 3
                                    color: "#58c706"

                                    Behavior on width {
                                        NumberAnimation { duration: 300 }
                                    }
                                }
                            }
                        }

                        // --- RAM ---
                        Column {
                            width: parent.width
                            spacing: 4

                            Text {
                                text: "RAM: " + sysStats.ramUsedGiB.toFixed(1) + " GiB / "
                                      + sysStats.ramTotalGiB.toFixed(1) + " GiB"
                                color: "#e6e6e7"
                            }

                            Rectangle {
                                width: parent.width
                                height: 6
                                radius: 3
                                color: "#3f3c46"

                                Rectangle {
                                    width: parent.width * (sysStats.ramPercent / 100)
                                    height: parent.height
                                    radius: 3
                                    color: "#ffb458"

                                    Behavior on width {
                                        NumberAnimation { duration: 300 }
                                    }
                                }
                            }
                        }

                        // --- Disk ---
                        Column {
                            width: parent.width
                            spacing: 4

                            Text {
                                text: "Disk: " + sysStats.diskUsedGiB.toFixed(0) + " GiB / "
                                      + sysStats.diskTotalGiB.toFixed(0) + " GiB"
                                color: "#e6e6e7"
                            }

                            Rectangle {
                                width: parent.width
                                height: 6
                                radius: 3
                                color: "#3f3c46"

                                Rectangle {
                                    width: parent.width * (sysStats.diskPercent / 100)
                                    height: parent.height
                                    radius: 3
                                    color: "#7aa2f7"

                                    Behavior on width {
                                        NumberAnimation { duration: 300 }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}