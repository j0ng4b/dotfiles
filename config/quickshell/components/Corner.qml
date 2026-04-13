import QtQuick.Shapes
import QtQuick

Shape {
    id: root

    enum Side {
        TopLeft,
        TopRight,
        BottomLeft,
        BottomRight
    }

    property var side
    property real size: 18
    property color color

    implicitWidth: size
    implicitHeight: size

    layer.enabled: true
    layer.smooth: true
    layer.samples: 4

    ShapePath {
        strokeWidth: 0
        fillColor: root.color

        PathAngleArc {
            radiusX: root.size
            radiusY: root.size
            sweepAngle: 90

            startAngle: {
                switch (root.side) {
                case Corner.Side.TopLeft:
                    return 180;
                case Corner.Side.TopRight:
                    return -90;
                case Corner.Side.BottomLeft:
                    return 90;
                case Corner.Side.BottomRight:
                    return 0;
                }
            }

            centerX: {
                switch (root.side) {
                case Corner.Side.TopLeft:
                    return root.size;
                case Corner.Side.TopRight:
                    return 0;
                case Corner.Side.BottomLeft:
                    return root.size;
                case Corner.Side.BottomRight:
                    return 0;
                }
            }

            centerY: {
                switch (root.side) {
                case Corner.Side.TopLeft:
                    return root.size;
                case Corner.Side.TopRight:
                    return root.size;
                case Corner.Side.BottomLeft:
                    return 0;
                case Corner.Side.BottomRight:
                    return 0;
                }
            }
        }

        PathLine {
            x: {
                switch (root.side) {
                case Corner.Side.TopLeft:
                    return 0;
                case Corner.Side.TopRight:
                    return root.size;
                case Corner.Side.BottomLeft:
                    return 0;
                case Corner.Side.BottomRight:
                    return root.size;
                }
            }

            y: {
                switch (root.side) {
                case Corner.Side.TopLeft:
                    return 0;
                case Corner.Side.TopRight:
                    return 0;
                case Corner.Side.BottomLeft:
                    return root.size;
                case Corner.Side.BottomRight:
                    return root.size;
                }
            }
        }
    }
}
