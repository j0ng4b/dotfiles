pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    signal outputsUpdated
    signal workspacesUpdated

    // Normalized outputs list
    //
    // {
    //   name, make, model, serial, focused,
    //   x, y, width, height, scale, transform,
    //   vrrSupported, vrrEnabled,
    //   currentMode: { width, height, refreshRate },
    //   modes: [{ width, height, refreshRate, label, isPreferred }]
    // }
    property var outputs: []
    property string focusedOutput: ''

    property ListModel workspaces: ListModel {}

    function focusOutput(name) {
        Quickshell.execDetached(['niri', 'msg', 'action', 'focus-monitor', name]);
    }

    function focusWorkspace(index) {
        Quickshell.execDetached(['niri', 'msg', 'action', 'focus-workspace', index]);
    }

    function refreshOutputs() {
        outputFetcher.running = true;
    }

    function updateWorkspaces(newWorkspaces) {
        newWorkspaces.sort((a, b) => parseInt(a.idx) - parseInt(b.idx));
        workspaces.clear();

        for (const workspace of newWorkspaces)
            workspaces.append({
                id: workspace.id,
                index: workspace.idx,
                active: workspace.is_active,
                output: workspace.output
            });

        root.workspacesUpdated();
    }

    function activateWorkspace(id) {
        let newActiveWorkspace = null;
        for (let i = 0; i < workspaces.count && newActiveWorkspace === null; i++)
            if (workspaces.get(i).id === id)
                newActiveWorkspace = workspaces.get(i);

        for (let i = 0; i < workspaces.count; i++) {
            const value = workspaces.get(i);
            if (value.output !== newActiveWorkspace.output)
                continue;

            workspaces.set(i, {
                id: value.id,
                index: value.index,
                active: value.id === newActiveWorkspace.id,
                output: value.output
            });
        }

        root.focusedOutput = newActiveWorkspace.output;
        root.workspacesUpdated();
    }

    function _parseRefresh(raw) {
        return raw ? raw / 1000 : 0;
    }

    function _modeLabel(w, h, hz) {
        return w + 'x' + h + '@' + Number(hz).toFixed(3);
    }

    function _parseOutputs(json) {
        try {
            const raw = JSON.parse(json);
            const result = [];

            for (const name in raw) {
                const output = raw[name];
                const logical = output.logical;

                const modes = (output.modes || []).map(mode => {
                    const hz = root._parseRefresh(mode.refresh_rate);
                    return {
                        width:       mode.width,
                        height:      mode.height,
                        refreshRate: hz,
                        label:       root._modeLabel(mode.width, mode.height, hz),
                        isPreferred: mode.is_preferred || false
                    };
                });

                const currentMode = modes[output.current_mode];
                const currentHz = currentMode.refreshRate;

                result.push({
                    name:         name,
                    make:         output.make  || '',
                    model:        output.model || '',
                    serial:       output.serial || '',
                    focused:      name === root.focusedOutput,

                    x:            logical ? logical.x : 0,
                    y:            logical ? logical.y : 0,
                    scale:        logical ? logical.scale : 1.0,
                    width:        logical ? logical.width : (currentMode ? currentMode.width : 0),
                    height:       logical ? logical.height : (currentMode ? currentMode.height : 0),
                    disabled:     logical === null,
                    transform:    logical ? logical.transform.toLowerCase() : 'normal',

                    vrrSupported: output.vrr_supported || false,
                    vrrEnabled:   output.vrr_enabled   || false,

                    currentMode: {
                        refreshRate: currentHz,
                        width:       currentMode.width,
                        height:      currentMode.height,
                        label: root._modeLabel(
                            currentMode.width,
                            currentMode.height,
                            currentHz
                        )
                    },

                    modes: modes
                });
            }

            result.sort((a, b) => {
                if (a.focused !== b.focused)
                    return a.focused ? -1 : 1;

                return a.name.localeCompare(b.name);
            });

            root.outputs = result;
            root.outputsUpdated();
        } catch (e) {
            console.warn('NiriService: failed to parse outputs:', e);
        }
    }

    // Listener for niri events
    Process {
        id: eventListener
        running: true
        command: ['niri', 'msg', '--json', 'event-stream']
        stdout: SplitParser {
            onRead: data => {
                const event = JSON.parse(data.trim());
                if (event.WorkspacesChanged)
                    root.updateWorkspaces(event.WorkspacesChanged.workspaces);
                else if (event.WorkspaceActivated)
                    root.activateWorkspace(event.WorkspaceActivated.id);
            }
        }
    }

    Process {
        running: true
        command: ['niri', 'msg', '--json', 'focused-output']
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const output = JSON.parse(this.text.trim());
                    if (output?.name)
                        root.focusedOutput = output.name;
                } catch (e) {
                    console.warn('Niri: failed to parse focused-output:', e);
                }
            }
        }
    }

    Process {
        id: outputFetcher
        running: false
        command: ['niri', 'msg', '--json', 'outputs']
        stdout: StdioCollector {
            onStreamFinished: root._parseOutputs(this.text.trim())
        }
    }
}
