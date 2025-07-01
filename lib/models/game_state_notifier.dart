
import 'package:flutter/material.dart';
import 'package:flutter_zip_game/models/level_data.dart';
import '../models/game_state.dart';
import '../models/grid_cell.dart';
import '../models/path_point.dart';
import '../services/hint_system.dart';
import '../services/level_generator.dart';
import '../services/path_validator.dart';

class GameStateNotifier extends ChangeNotifier {
  late GameState _gameState;
  late List<PathPoint> _solutionPath;
  PathPoint? _lastPoint;
  PathPoint? _hintPoint;

  GameState get gameState => _gameState;
  PathPoint? get hintPoint => _hintPoint;

  GameStateNotifier({required int gridSize, required Difficulty difficulty}) {
    initializeGame(gridSize, difficulty);
  }

  void initializeGame(int gridSize, Difficulty difficulty) {
    final LevelData level = LevelGenerator.generateLevel(gridSize, difficulty);
    _solutionPath = level.solutionPath;
    _gameState = GameState(
      grid: level.grid,
      currentPath: [],
      currentNumber: 1,
      isComplete: false,
      gridSize: gridSize,
      totalNumbers: level.totalNumbers,
      status: GameStatus.notStarted,
    );
    _hintPoint = null;
    _lastPoint = null;
    notifyListeners();
  }

  void undo() {
    _gameState = _gameState.undo();
    notifyListeners();
  }

  void redo() {
    _gameState = _gameState.redo();
    notifyListeners();
  }

  bool get canUndo => _gameState.canUndo;
  bool get canRedo => _gameState.canRedo;

  void showHint() {
    final hint = HintSystem.getNextHint(_gameState, _solutionPath);
    if (hint != null) {
      _hintPoint = hint;
      notifyListeners();
      Future.delayed(const Duration(seconds: 1), () {
        _hintPoint = null;
        notifyListeners();
      });
    }
  }

  void onPanStart(Offset detailsLocalPosition, double cellSize) {
    if (_gameState.status == GameStatus.success) return;
    _hintPoint = null;
    final point = _pointFromOffset(detailsLocalPosition, cellSize);
    if (point == null) return;

    final cell = _gameState.grid[point.row][point.col];
    if (cell.number == 1) {
      _gameState = _gameState.copyWith(
        currentPath: [point],
        status: GameStatus.playing,
        currentNumber: 2,
      ).recordState();
      _lastPoint = point;
      notifyListeners();
    }
  }

  void onPanUpdate(Offset detailsLocalPosition, double cellSize) {
    if (_gameState.status != GameStatus.playing) return;

    final currentGridPoint = _pointFromOffset(detailsLocalPosition, cellSize);
    if (currentGridPoint == null) return;

    // If the user is trying to go back to the previous point (backtracking)
    if (_gameState.currentPath.length > 1 &&
        currentGridPoint.row == _gameState.currentPath[_gameState.currentPath.length - 2].row &&
        currentGridPoint.col == _gameState.currentPath[_gameState.currentPath.length - 2].col) {
      _gameState = _gameState.copyWith(
        currentPath: List<PathPoint>.from(_gameState.currentPath)..removeLast(),
      );
      _lastPoint = _gameState.currentPath.last;
      final cell = _gameState.grid[_lastPoint!.row][_lastPoint!.col];
      if (cell.number != null && cell.number! < _gameState.currentNumber) {
        _gameState = _gameState.copyWith(currentNumber: cell.number! + 1);
      }
      _gameState = _gameState.recordState();
      notifyListeners();
      return;
    }

    // If the user is trying to move to the same point, do nothing
    if (_lastPoint != null && currentGridPoint.row == _lastPoint!.row && currentGridPoint.col == _lastPoint!.col) {
      return;
    }

    // Check if the new point is a valid next step (adjacent and not already in path, unless it's a number)
    final isAdjacent = (currentGridPoint.row - _lastPoint!.row).abs() +
            (currentGridPoint.col - _lastPoint!.col).abs() ==
        1;
    final isAlreadyInPath = _gameState.currentPath.any(
        (p) => p.row == currentGridPoint.row && p.col == currentGridPoint.col);
    final isNumberedCell = _gameState.grid[currentGridPoint.row][currentGridPoint.col].number != null;

    if (isAdjacent && (!isAlreadyInPath || isNumberedCell)) {
      final newPath = List<PathPoint>.from(_gameState.currentPath)..add(currentGridPoint);

      if (PathValidator.isValidPath(newPath, _gameState.grid)) {
        final cell = _gameState.grid[currentGridPoint.row][currentGridPoint.col];
        int nextNumber = _gameState.currentNumber;
        if (cell.number == nextNumber) {
          nextNumber++;
        }

        _gameState = _gameState.copyWith(
          currentPath: newPath,
          currentNumber: nextNumber,
        ).recordState();
        _lastPoint = currentGridPoint;
        notifyListeners();
      }
    }
  }

  GameStatus onPanEnd() {
    if (_gameState.status != GameStatus.playing) return _gameState.status;

    if (PathValidator.checkWinCondition(_gameState)) {
      _gameState = _gameState.copyWith(status: GameStatus.success);
      notifyListeners();
      return GameStatus.success;
    } else {
      _gameState = _gameState.trimHistory();
      notifyListeners();
      return _gameState.status; // Return current status (still playing or notStarted if path is empty)
    }
  }

  PathPoint? _pointFromOffset(Offset offset, double cellSize) {
    final row = (offset.dy / cellSize).floor();
    final col = (offset.dx / cellSize).floor();

    if (row >= 0 && row < _gameState.gridSize && col >= 0 && col < _gameState.gridSize) {
      return PathPoint(row: row, col: col, order: _gameState.currentPath.length);
    }
    return null;
  }
}
