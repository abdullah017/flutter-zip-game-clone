
import 'grid_cell.dart';
import 'path_point.dart';

class LevelData {
  final List<List<GridCell>> grid;
  final int gridSize;
  final int totalNumbers;
  final List<PathPoint> solutionPath;

  LevelData({
    required this.grid,
    required this.gridSize,
    required this.totalNumbers,
    required this.solutionPath,
  });
}
