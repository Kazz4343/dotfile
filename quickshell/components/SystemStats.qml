import QtQuick
import Quickshell.Io

// Non-visual "data source" component: polls the system every couple
// seconds and exposes ready-to-bind percentages/sizes. Drop this
// anywhere and read its properties — no UI logic lives in here.
//
// Usage:
//   SystemStats { id: sysStats }
//   Text { text: sysStats.cpuPercent + "%" }
Item {
    id: root

    readonly property int cpuPercent: _cpuPercent
    readonly property real ramUsedGiB: _ramUsedGiB
    readonly property real ramTotalGiB: _ramTotalGiB
    readonly property int ramPercent: _ramTotalGiB > 0 ? Math.round((_ramUsedGiB / _ramTotalGiB) * 100) : 0
    readonly property real diskUsedGiB: _diskUsedGiB
    readonly property real diskTotalGiB: _diskTotalGiB
    readonly property int diskPercent: _diskTotalGiB > 0 ? Math.round((_diskUsedGiB / _diskTotalGiB) * 100) : 0

    property int _cpuPercent: 0
    property real _ramUsedGiB: 0
    property real _ramTotalGiB: 0
    property real _diskUsedGiB: 0
    property real _diskTotalGiB: 0

    // /proc/stat gives cumulative counters since boot, so CPU% has to be
    // derived from the *change* between two samples, not a single read.
    property var _prevCpuSample: null

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuProc.running = true
            memProc.running = true
            diskProc.running = true
        }
    }

    // --- CPU: /proc/stat ---
    // First line looks like:
    // cpu  user nice system idle iowait irq softirq steal guest guest_nice
    Process {
        id: cpuProc
        command: ["cat", "/proc/stat"]
        stdout: StdioCollector {
            onStreamFinished: {
                const firstLine = this.text.split("\n")[0]
                const f = firstLine.trim().split(/\s+/).slice(1).map(Number)
                const idle = f[3] + f[4]
                const nonIdle = f[0] + f[1] + f[2] + f[5] + f[6] + f[7]
                const total = idle + nonIdle

                if (root._prevCpuSample) {
                    const totalDelta = total - root._prevCpuSample.total
                    const idleDelta = idle - root._prevCpuSample.idle
                    root._cpuPercent = totalDelta > 0
                        ? Math.round((1 - idleDelta / totalDelta) * 100)
                        : 0
                }
                root._prevCpuSample = { idle: idle, total: total }
            }
        }
    }

    // --- RAM: /proc/meminfo (values are in kB) ---
    Process {
        id: memProc
        command: ["cat", "/proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.split("\n")
                let totalKb = 0
                let availKb = 0
                for (const line of lines) {
                    if (line.startsWith("MemTotal:"))
                        totalKb = parseInt(line.match(/\d+/)[0])
                    else if (line.startsWith("MemAvailable:"))
                        availKb = parseInt(line.match(/\d+/)[0])
                }
                root._ramTotalGiB = totalKb / (1024 * 1024)
                root._ramUsedGiB = (totalKb - availKb) / (1024 * 1024)
            }
        }
    }

    // --- Disk: df on / , in bytes so there's no unit-suffix parsing ---
    Process {
        id: diskProc
        command: ["df", "-B1", "/"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n")
                if (lines.length < 2) return
                const fields = lines[1].trim().split(/\s+/)
                const totalBytes = parseInt(fields[1])
                const usedBytes = parseInt(fields[2])
                root._diskTotalGiB = totalBytes / (1024 * 1024 * 1024)
                root._diskUsedGiB = usedBytes / (1024 * 1024 * 1024)
            }
        }
    }
}