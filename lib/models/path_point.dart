
enum Direction {
  up,
  down,
  left,
  right,
  none,
}

class PathPoint {
  final int row;
  final int col;
  final int order; // path üzerindeki sıra
  final Direction fromDirection;
  final Direction toDirection;

  PathPoint({
    required this.row,
    required this.col,
    required this.order,
    this.fromDirection = Direction.none,
    this.toDirection = Direction.none,
  });

   PathPoint copyWith({
    int? row,
    int? col,
    int? order,
    Direction? fromDirection,
    Direction? toDirection,
  }) {
    return PathPoint(
      row: row ?? this.row,
      col: col ?? this.col,
      order: order ?? this.order,
      fromDirection: fromDirection ?? this.fromDirection,
      toDirection: toDirection ?? this.toDirection,
    );
  }
}
