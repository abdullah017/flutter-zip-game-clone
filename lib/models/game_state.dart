
import 'grid_cell.dart';
import 'path_point.dart';

enum GameStatus {
  playing,
  success,
  failure,
  notStarted,
}

class GameState {
  final List<List<GridCell>> grid;
  final List<PathPoint> currentPath;
  final int currentNumber;
  final bool isComplete;
  final int gridSize;
  final int totalNumbers;
  final GameStatus status;

  GameState({
    required this.grid,
    required this.currentPath,
    required this.currentNumber,
    required this.isComplete,
    required this.gridSize,
    required this.totalNumbers,
    required this.status,
  });

  GameState copyWith({
    List<List<GridCell>>? grid,
    List<PathPoint>? currentPath,
    int? currentNumber,
    bool? isComplete,
    int? gridSize,
    int? totalNumbers,
    GameStatus? status,
  }) {
    return GameState(
      grid: grid ?? this.grid,
      currentPath: currentPath ?? this.currentPath,
      currentNumber: currentNumber ?? this.currentNumber,
      isComplete: isComplete ?? this.isComplete,
      gridSize: gridSize ?? this.gridSize,
      totalNumbers: totalNumbers ?? this.totalNumbers,
      status: status ?? this.status,
    );
  }
}
