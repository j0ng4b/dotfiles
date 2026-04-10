import QtQuick

Text {
    id: root

    property bool fill: false
    property int size: 18
    required property string icon

    text: root.icon
    renderType: Text.NativeRendering
    antialiasing: true

    font.family: "Material Symbols Rounded"
    font.pixelSize: size
    font.hintingPreference: Font.PreferFullHinting
    font.variableAxes: {
        "FILL": root.fill ? 1 : 0,
        "opsz": root.fontInfo.pixelSize,
        "wght": root.fontInfo.weight
    }
}
