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

    color: 'transparent'
    exclusiveZone: contentHeight + 5

    implicitHeight: container.height
    property int contentHeight: 30


    Column {
      id: container

      Rectangle {
        color: Colorscheme.current.surface

        implicitWidth: content.width
        implicitHeight: content.height

        Item {
          id: content
          implicitWidth: bar.width
          implicitHeight: bar.contentHeight

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

      RowLayout {
        width: content.width

        Corner {
          side: Corner.Side.Left
          color: Colorscheme.current.surface
          Layout.alignment: Qt.AlignLeft
        }

        Corner {
          side: Corner.Side.Right
          color: Colorscheme.current.surface
          Layout.alignment: Qt.AlignRight
        }
      }
    }
  }
}

