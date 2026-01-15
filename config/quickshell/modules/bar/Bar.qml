import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.modules.bar.workspaces

Variants {
  model: Quickshell.screens
  delegate: PanelWindow {
    id: bar
    required property var modelData
    screen: modelData

    anchors.top: true
    anchors.left: true
    anchors.right: true

    implicitHeight: 30
    color: Colorscheme.current.background

    Workspaces {
      output: bar.screen
    }

    // Clock
    ColumnLayout {
      anchors.right: parent.right
      anchors.margins: 5
      spacing: 2

      Text {
        Layout.alignment: Qt.AlignCenter

        text: Clock.time
        font.pixelSize: 12
        color: Colorscheme.current.on_surface
      }

      Text {
        Layout.alignment: Qt.AlignCenter

        text: Clock.date
        font.pixelSize: 10
        color: Colorscheme.current.on_surface
      }
    }
  }
}

