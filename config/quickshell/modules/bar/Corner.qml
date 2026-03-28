import QtQuick.Shapes
import QtQuick

Shape {
    id: root

    enum Side {
        Left,
        Right
    }

    property var side
    property real size: 18
    property color color

    implicitWidth: size
    implicitHeight: size

    ShapePath {
        strokeWidth: 0
        fillColor: root.color

        PathAngleArc {
            startAngle: root.side == Corner.Side.Left ? 180 : -90
            sweepAngle: 90
            centerX: root.side == Corner.Side.Left ? root.size : 0
            centerY: root.size
            radiusX: root.size
            radiusY: root.size
        }

        PathLine {
            x: root.side == Corner.Side.Left ? 0 : root.size
            y: 0
        }
    }
}
