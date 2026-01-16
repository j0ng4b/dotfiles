import QtQuick.Shapes
import QtQuick

Shape {
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
    fillColor: color

    PathAngleArc {
      startAngle: side == Corner.Side.Left ? 180 : -90
      sweepAngle: 90
      centerX: side == Corner.Side.Left ? size : 0
      centerY: size
      radiusX: size
      radiusY: size
    }

    PathLine {
      x: side == Corner.Side.Left ? 0 : size
      y: 0
    }
  }
}
