import QtQuick
import QtQuick.Layouts

import qs.services

Item {
    id: workspaces
    property var output

    width: workspaceIndicator.implicitWidth
    height: workspaceIndicator.implicitHeight

    RowLayout {
        id: workspaceIndicator
        anchors.centerIn: parent
        spacing: 5

        property ListModel filteredWorkspaces: ListModel {}

        Repeater {
            model: workspaceIndicator.filteredWorkspaces
            delegate: WorkspaceEntry {}
        }

        Connections {
            target: CompositorService
            function onWorkspacesUpdated() {
                const model = workspaceIndicator.filteredWorkspaces;

                let existing = {};
                let incoming = {};

                for (let i = 0; i < model.count; i++)
                    existing[model.get(i).index] = i;

                for (let i = 0; i < CompositorService.workspaces.count; i++) {
                    let ws = CompositorService.workspaces.get(i);
                    if (ws.output === workspaces.output.name)
                        incoming[ws.index] = ws;
                }

                for (let idx in incoming)
                    if (existing[idx] !== undefined)
                        model.set(existing[idx], incoming[idx]);
                    else
                        model.append(incoming[idx]);

                for (let i = model.count - 1; i >= 0; i--)
                    if (incoming[model.get(i).index] === undefined)
                        model.remove(i);
            }
        }
    }
}
