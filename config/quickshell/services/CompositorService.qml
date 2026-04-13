pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    signal outputsUpdated
    signal workspacesUpdated

    property var outputs: []
    property string focusedOutput: ''
    property ListModel workspaces: ListModel {}

    property bool applying: false
    property string applyError: ''

    readonly property string compositor: _detected

    //
    // Public API
    //

    function focusOutput(name) {
        _active.focusOutput(name);
    }

    function focusWorkspace(index) {
        _active.focusWorkspace(index);
    }

    function refreshOutputs() {
        _active.refreshOutputs();
    }

    function applySettings(settings) {
        _active.applySettings(settings);
    }

    //
    // Compositor detections
    //

    property string _detected: ''

    readonly property var _active: {
        switch (_detected) {
        case 'niri':
            return niriAdapter;
        case 'mango':
            return mangoAdapter;
        default:
            return niriAdapter;
        }
    }

    onCompositorChanged: {
        if (compositor === 'niri') {
            niriAdapter.active = true;
            mangoAdapter.active = false;
        } else if (compositor === 'mango') {
            mangoAdapter.active = true;
            niriAdapter.active = false;
        }
    }

    Process {
        running: true
        command: ['sh', '-c', 'if [ -n "$NIRI_SOCKET" ] && command -v niri >/dev/null 2>&1; then echo niri; ' + 'elif command -v mmsg >/dev/null 2>&1; then echo mango; ' + 'else echo unknown; fi']
        stdout: StdioCollector {
            onStreamFinished: root._detected = this.text.trim()
        }
    }

    //
    // Adapters
    //

    NiriAdapter {
        id: niriAdapter
    }

    MangoAdapter {
        id: mangoAdapter
    }

    Component.onCompleted: {
        adapterConnection.createObject(root, {
            adapter: niriAdapter
        });

        adapterConnection.createObject(root, {
            adapter: mangoAdapter
        });
    }

    Component {
        id: adapterConnection

        Connections {
            required property var adapter

            target: adapter
            enabled: root._active === adapter

            function onWorkspacesUpdated() {
                root.workspaces.clear();
                for (let i = 0; i < adapter.workspaces.count; i++)
                    root.workspaces.append(adapter.workspaces.get(i));
                root.workspacesUpdated();
            }

            function onOutputsUpdated() {
                root.outputs = adapter.outputs;
                root.outputsUpdated();
            }

            function onFocusedOutputChanged() {
                root.focusedOutput = adapter.focusedOutput;
            }

            function onApplyingChanged() {
                root.applying = adapter.applying;
            }

            function onApplyErrorChanged() {
                root.applyError = adapter.applyError;
            }
        }
    }

    //
    // NiriAdapter
    //

    component NiriAdapter: QtObject {
        id: niri

        signal outputsUpdated
        signal workspacesUpdated

        property var outputs: []
        property string focusedOutput: ''
        property ListModel workspaces: ListModel {}
        property bool applying: false
        property string applyError: ''

        property bool active: false
        onActiveChanged: if (active)
            _init()

        function _init() {
            _eventListener.running = true;
            _focusedOutputFetcher.running = true;
        }

        // API
        function focusOutput(name) {
            Quickshell.execDetached(['niri', 'msg', 'action', 'focus-monitor', name]);
        }

        function focusWorkspace(index) {
            Quickshell.execDetached(['niri', 'msg', 'action', 'focus-workspace', String(index)]);
        }

        function refreshOutputs() {
            _outputFetcher.running = true;
        }

        function applySettings(outputsSettings) {
            if (applying)
                return;
            applyError = '';

            const cmds = [];
            for (const name in outputsSettings) {
                const settings = outputsSettings[name];
                if (!settings.dirty)
                    continue;

                const base = ['niri', 'msg', 'output', name];
                if (settings.mode)
                    cmds.push([...base, 'mode', settings.mode]);
                if (settings.scale)
                    cmds.push([...base, 'scale', String(settings.scale)]);
                if (settings.transform)
                    cmds.push([...base, 'transform', settings.transform]);
                cmds.push([...base, 'position', 'set', '--', Math.round(settings.x), Math.round(settings.y)]);
            }

            if (cmds.length === 0)
                return;

            applying = true;
            _queue = cmds;
            _queueIdx = 0;
            _runNext();
        }

        // Internals
        property var _queue: []
        property int _queueIdx: 0

        function _runNext() {
            if (_queueIdx >= _queue.length) {
                applying = false;
                _queueIdx = 0;
                _queue = [];
                refreshOutputs();
                return;
            }

            _applyRunner.command = _queue[_queueIdx];
            _applyRunner.running = true;
        }

        function _hz(raw) {
            return raw ? raw / 1000 : 0;
        }

        function _label(w, h, hz) {
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
                        const hz = niri._hz(mode.refresh_rate);
                        return {
                            width: mode.width,
                            height: mode.height,
                            refreshRate: hz,
                            label: niri._label(mode.width, mode.height, hz),
                            isPreferred: mode.is_preferred || false
                        };
                    });

                    const currentMode = output.current_mode ? modes[output.current_mode] : modes[0];
                    result.push({
                        name,
                        make: output.make || '',
                        model: output.model || '',
                        serial: output.serial || '',
                        focused: name === niri.focusedOutput,
                        x: logical ? logical.x : 0,
                        y: logical ? logical.y : 0,
                        scale: logical ? logical.scale : 1.0,
                        width: logical ? logical.width : (currentMode ? currentMode.width : 0),
                        height: logical ? logical.height : (currentMode ? currentMode.height : 0),
                        disabled: logical === null,
                        transform: logical ? logical.transform.toLowerCase() : 'normal',
                        vrrSupported: output.vrr_supported || false,
                        vrrEnabled: output.vrr_enabled || false,
                        currentMode: currentMode ? {
                            refreshRate: currentMode.refreshRate,
                            width: currentMode.width,
                            height: currentMode.height,
                            label: niri._label(currentMode.width, currentMode.height, currentMode.refreshRate)
                        } : null,
                        modes
                    });
                }

                result.sort((a, b) => {
                    if (a.focused !== b.focused)
                        return a.focused ? -1 : 1;

                    return a.name.localeCompare(b.name);
                });

                niri.outputs = result;
                niri.outputsUpdated();
            } catch (e) {
                console.warn('NiriAdapter: parse outputs failed:', e);
            }
        }

        function _updateWorkspaces(newWorkspaces) {
            newWorkspaces.sort((a, b) => parseInt(a.idx) - parseInt(b.idx));
            workspaces.clear();

            for (const workspace of newWorkspaces)
                workspaces.append({
                    id: workspace.id,
                    index: workspace.idx,
                    active: workspace.is_active,
                    output: workspace.output
                });

            niri.workspacesUpdated();
        }

        function _activateWorkspace(id) {
            let newActiveWorkspace = null;
            for (let i = 0; i < workspaces.count && newActiveWorkspace === null; i++)
                if (workspaces.get(i).id === id)
                    newActiveWorkspace = workspaces.get(i);

            if (!newActiveWorkspace)
                return;

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

            niri.focusedOutput = newActiveWorkspace.output;
            niri.workspacesUpdated();
        }

        property Process _eventListener: Process {
            running: false
            command: ['niri', 'msg', '--json', 'event-stream']
            stdout: SplitParser {
                onRead: data => {
                    try {
                        const event = JSON.parse(data.trim());
                        if (event.WorkspacesChanged)
                            niri._updateWorkspaces(event.WorkspacesChanged.workspaces);
                        else if (event.WorkspaceActivated)
                            niri._activateWorkspace(event.WorkspaceActivated.id);
                    } catch (e) {
                        console.warn('NiriAdapter: event parse error:', e);
                    }
                }
            }
        }

        property Process _focusedOutputFetcher: Process {
            running: false
            command: ['niri', 'msg', '--json', 'focused-output']
            stdout: StdioCollector {
                onStreamFinished: {
                    try {
                        const output = JSON.parse(this.text.trim());
                        if (output?.name)
                            niri.focusedOutput = output.name;
                    } catch (e) {
                        console.warn('NiriAdapter: focused-output parse error:', e);
                    }
                }
            }
        }

        property Process _outputFetcher: Process {
            running: false
            command: ['niri', 'msg', '--json', 'outputs']
            stdout: StdioCollector {
                onStreamFinished: niri._parseOutputs(this.text.trim())
            }
        }

        property Process _applyRunner: Process {
            running: false
            stderr: StdioCollector {
                onStreamFinished: {
                    const err = this.text.trim();
                    if (err)
                        niri.applyError = err;
                }
            }
            onExited: code => {
                if (code !== 0) {
                    niri.applying = false;
                    niri._queueIdx = 0;
                    niri._queue = [];
                } else {
                    niri._queueIdx++;
                    niri._runNext();
                }
            }
        }
    }

    //
    // Mango
    //

    component MangoAdapter: QtObject {
        id: mango

        signal outputsUpdated
        signal workspacesUpdated

        property var outputs: []
        property string focusedOutput: ''
        property ListModel workspaces: ListModel {}
        property bool applying: false
        property string applyError: ''

        property bool active: false
        onActiveChanged: if (active)
            _init()

        function _init() {
            _eventListener.running = true;
            _outputFetcher.running = true;
        }

        // API
        function focusOutput(name) {
            // Not working:
            // Quickshell.execDetached(['mmsg', '-s', '-o', name]);
            Quickshell.execDetached(['mmsg', '-s', 'focusmon,' + name]);
        }

        function focusWorkspace(index) {
            Quickshell.execDetached(['mmsg', '-s', '-t', String(index)]);
        }

        function refreshOutputs() {
            _outputFetcher.running = true;
        }

        function applySettings(_) {
            applyError = 'Output configuration not supported via mmsg. Use wlr-randr.';
        }

        // Internal state
        // _tagState[outputName][tagIndex] = { clients, active, urgent }
        property var _tagState: ({})

        property Process _eventListener: Process {
            running: false
            command: ['mmsg', '-w', '-o', '-t']
            stdout: SplitParser {
                onRead: data => mango._parseLine(data.trim())
            }
        }

        function _parseLine(line) {
            if (!line)
                return;

            // "<output> selmon <0|1>"
            const selmon = /^(\S+)\s+selmon\s+([01])$/.exec(line);
            if (selmon) {
                if (selmon[2] === '1')
                    mango.focusedOutput = selmon[1];
                return;
            }

            // "<output> tag <N> <state> <clients> <focused_client>"
            //   state: 0=none  1=active  2=urgent
            const tag = /^(\S+)\s+tag\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)$/.exec(line);
            if (tag) {
                const output = tag[1];
                const tagNum = parseInt(tag[2]);
                const state = parseInt(tag[3]);
                const clients = parseInt(tag[4]);

                if (!mango._tagState[output])
                    mango._tagState[output] = {};

                if (clients > 0 || state === 1)
                    mango._tagState[output][tagNum] = {
                        clients,
                        active: state === 1,
                        urgent: state === 2
                    };
                else
                    delete mango._tagState[output][tagNum];

                mango._rebuildWorkspaces();
            }
        }

        function _rebuildWorkspaces() {
            workspaces.clear();
            for (const output in mango._tagState) {
                const tags = mango._tagState[output];
                const sorted = Object.keys(tags).map(Number).sort((a, b) => a - b);

                for (const tagNum of sorted)
                    workspaces.append({
                        id: output + ':' + tagNum,
                        index: tagNum,
                        active: tags[tagNum].active,
                        output
                    });

                const lastOccupied = sorted.length > 0 ? sorted[sorted.length - 1] : 0;
                const nextEmpty = lastOccupied + 1;
                if (nextEmpty <= 9 && (tags[lastOccupied].clients > 0))
                    workspaces.append({
                        id: output + ':' + nextEmpty,
                        index: nextEmpty,
                        active: false,
                        output
                    });
            }

            mango.workspacesUpdated();
        }

        property Process _outputFetcher: Process {
            running: false
            command: ['mmsg', '-O']
            stdout: StdioCollector {
                onStreamFinished: mango._parseOutputs(this.text.trim())
            }
        }

        function _parseOutputs(text) {
            const result = [];

            for (const line of text.split('\n')) {
                const name = line.trim();
                if (!name)
                    continue;

                result.push({
                    name,
                    make: '',
                    model: '',
                    serial: '',
                    focused: name === mango.focusedOutput,
                    x: 0,
                    y: 0,
                    width: 0,
                    height: 0,
                    scale: 1.0,
                    transform: 'normal',
                    disabled: false,
                    vrrSupported: false,
                    vrrEnabled: false,
                    currentMode: null,
                    modes: []
                });
            }

            mango.outputs = result;
            mango.outputsUpdated();
        }
    }
}
