pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: clock

  property string time
  property string date

  Process {
    id: timeDateFetcher
    running: true
    command: ['date', '+"%H:%M;%a, %d %b"']

    stdout: StdioCollector {
      onStreamFinished: {
        const parts = this.text.replace(/"/g, '').split(';')
        clock.time = parts[0]
        clock.date = parts[1]
      }
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true

    onTriggered: timeDateFetcher.running = true
  }
}

