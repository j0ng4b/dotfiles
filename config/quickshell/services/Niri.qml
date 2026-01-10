pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root
  property ListModel workspaces: ListModel {}

  signal workspacesUpdated()


  function focusWorkspace(index) {
    Quickshell.execDetached(['niri', 'msg', 'action', 'focus-workspace', index])
  }

  function updateWorkspaces(newWorkspaces) {
    newWorkspaces.sort((a, b) => parseInt(a.idx) - parseInt(b.idx))
    workspaces.clear()

    for (const workspace of newWorkspaces)
      workspaces.append({
        id: workspace.id,
        index: workspace.idx,
        active: workspace.is_active,
        output: workspace.output
      })

    root.workspacesUpdated()
  }

  function activateWorkspace(id) {
    let newActiveWorkspace = null
    for (let i = 0; i < workspaces.count && newActiveWorkspace === null; i++)
      if (workspaces.get(i).id === id)
        newActiveWorkspace = workspaces.get(i)

    for (let i = 0; i < workspaces.count; i++) {
      const value = workspaces.get(i)
      if (value.output !== newActiveWorkspace.output)
        continue

      workspaces.set(i, {
        id: value.id,
        index: value.index,
        active: value.id === newActiveWorkspace.id,
        output: value.output
      })
    }

    root.workspacesUpdated()
  }

  Process {
    id: eventListener
    running: true
    command: ['niri', 'msg', '--json', 'event-stream']

    stdout: SplitParser {
      onRead: data => {
        const event = JSON.parse(data.trim())

        if (event.WorkspacesChanged)
          root.updateWorkspaces(event.WorkspacesChanged.workspaces)
        else if (event.WorkspaceActivated)
          root.activateWorkspace(event.WorkspaceActivated.id)
      }
    }
  }
}

