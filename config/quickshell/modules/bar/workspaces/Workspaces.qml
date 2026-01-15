import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services

Rectangle {
  id: workspaces
  property var output

  anchors.centerIn: parent
  color: Colorscheme.current.surface_container_high

  width: workspaceIndicator.implicitWidth + 24
  height: workspaceIndicator.implicitHeight + 12
  radius: 10

  RowLayout {
    id: workspaceIndicator
    anchors.centerIn: parent
    anchors.margins: 5
    spacing: 5

    property ListModel filteredWorkspaces: ListModel {}


    Repeater {
      model: workspaceIndicator.filteredWorkspaces
      delegate: WorkspaceEntry { }
    }

    Connections {
      target: Niri
      function onWorkspacesUpdated() {
        workspaceIndicator.filteredWorkspaces.clear();

        for (let i = 0; i < Niri.workspaces.count; i++) {
          let ws = Niri.workspaces.get(i);
          if (ws.output === workspaces.output.name)
          workspaceIndicator.filteredWorkspaces.append(ws);
        }
      }
    }
  }
}
