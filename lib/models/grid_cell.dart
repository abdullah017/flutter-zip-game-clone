
class GridCell {
  final int row;
  final int col;
  final int? number; // null ise boş hücre
  final bool isVisited;
  final bool isWall; // engel hücreler için

  GridCell({
    required this.row,
    required this.col,
    this.number,
    this.isVisited = false,
    this.isWall = false,
  });

  GridCell copyWith({
    int? row,
    int? col,
    int? number,
    bool? isVisited,
    bool? isWall,
  }) {
    return GridCell(
      row: row ?? this.row,
      col: col ?? this.col,
      number: number ?? this.number,
      isVisited: isVisited ?? this.isVisited,
      isWall: isWall ?? this.isWall,
    );
  }
}
