pragma Singleton

import Quickshell
import QtQuick

import qs.services

Singleton {
    id: root

    readonly property int snap: 10

    property bool open: false
    property string selectedOutput: ''

    // [output_name] = { x, y, mode, scale, transform, dirty }
    property var _settings: ({})

    function toggle() {
        open = !open;
        if (open)
            NiriService.refreshOutputs();
        else
            _clearSettings();
    }

    function close() {
        open = false;
        _clearSettings();
    }

    function selectOutput(name) {
        selectedOutput = name;
    }

    function _syncSelection() {
        const outputs = NiriService.outputs;
        if (outputs.length === 0) {
            selectedOutput = '';
            return;
        }

        if (!outputs.some(output => output.name === selectedOutput))
            selectedOutput = (outputs.find(output => output.focused) || outputs[0]).name;

        for (const output of outputs)
            if (!_settings[output.name])
                _initSettings(output);
    }

    function _initSettings(output) {
        const settings = root._settings;
        settings[output.name] = {
            x: output.x,
            y: output.y,
            mode: output.currentMode ? output.currentMode.label : '',
            scale: output.scale,
            transform: output.transform,
            dirty: false
        };

        // Trigger binding
        root._settings = Object.assign({}, settings);
    }

    function _clearSettings() {
        root._settings = {};
    }

    function getSettings(name) {
        return root._settings[name] ?? null;
    }

    function isDirty(name) {
        return root._settings[name]?.dirty ?? false;
    }

    function hasDirtyOutputs() {
        for (const output in root._settings)
            if (root._settings[output].dirty)
                return true;

        return false;
    }

    // Patch output settings (any of { x,y,mode,scale,transform })
    function patchSettings(name, patch) {
        const settings = Object.assign({}, root._settings);
        if (!settings[name])
            return;

        settings[name] = Object.assign({}, settings[name], patch, {
            dirty: true
        });

        root._settings = settings;
    }

    function dragOutput(name, newX, newY) {
        patchSettings(name, {
            x: Math.round(newX / snap) * snap,
            y: Math.round(newY / snap) * snap
        });
    }

    function nudgeSelected(dx, dy) {
        const name = selectedOutput;
        const settings = root._settings[name];
        if (!settings)
            return;

        patchSettings(name, {
            x: settings.x + dx * snap,
            y: settings.y + dy * snap
        });
    }

    function resetSettings(name) {
        const output = NiriService.outputs.find(output => output.name === name);
        if (output)
            _initSettings(output);
    }

    function resetAllSettings() {
        for (const output of NiriService.outputs)
            _initSettings(output);
    }

    function applyAll() {
        NiriService.applySettings(root._settings);
    }

    Connections {
        target: NiriService
        function onOutputsUpdated() {
            MonitorState._syncSelection();

            const settings = Object.assign({}, root._settings);
            let changed = false;
            for (const name in settings) {
                if (settings[name].dirty && !NiriService.applying) {
                    const output = NiriService.outputs.find(output => output.name === name);
                    if (output) {
                        settings[name] = {
                            x: output.x,
                            y: output.y,
                            mode: output.currentMode?.label ?? '',
                            scale: output.scale,
                            transform: output.transform,
                            dirty: false
                        };

                        changed = true;
                    }
                }
            }

            if (changed)
                root._settings = settings;
        }
    }
}
