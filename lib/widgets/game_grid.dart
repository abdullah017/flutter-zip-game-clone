
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../models/grid_cell.dart';
import '../models/level_data.dart';
import '../models/path_point.dart';
import '../services/hint_system.dart';
import '../services/level_generator.dart';
import '../services/path_validator.dart';

import 'grid_cell_widget.dart';
import 'path_painter.dart';

class GameGrid extends StatefulWidget {
  final int gridSize;
  final Difficulty difficulty;

  const GameGrid({Key? key, required this.gridSize, required this.difficulty}) : super(key: key);

  @override
  GameGridState createState() => GameGridState();
}

class GameGridState extends State<GameGrid> with TickerProviderStateMixin {
  late GameState _gameState;
  late List<PathPoint> _solutionPath;
  PathPoint? _lastPoint;
  PathPoint? _hintPoint;
  late AnimationController _pathAnimationController;
  late AnimationController _successAnimationController;
  late Animation<double> _successAnimation;

  @override
  void initState() {
    super.initState();
    _pathAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _successAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _successAnimation = CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.elasticOut,
    );
    initializeGame();
  }

  void initializeGame() {
    final LevelData level = LevelGenerator.generateLevel(widget.gridSize, widget.difficulty);
    _solutionPath = level.solutionPath;
    setState(() {
      _gameState = GameState(
        grid: level.grid,
        currentPath: [],
        currentNumber: 1,
        isComplete: false,
        gridSize: widget.gridSize,
        totalNumbers: level.totalNumbers,
        status: GameStatus.notStarted,
      );
      _hintPoint = null;
    });
    _pathAnimationController.forward(from: 0.0);
    _successAnimationController.reset();
  }

  void undo() {
    setState(() {
      _gameState = _gameState.undo();
    });
  }

  void redo() {
    setState(() {
      _gameState = _gameState.redo();
    });
  }

  bool get canUndo => _gameState.canUndo;
  bool get canRedo => _gameState.canRedo;
  
  @override
  void dispose() {
    _pathAnimationController.dispose();
    _successAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cellSize = constraints.maxWidth / widget.gridSize;

        return GestureDetector(
          onPanStart: (details) => _onPanStart(details, cellSize),
          onPanUpdate: (details) => _onPanUpdate(details, cellSize),
          onPanEnd: (details) => _onPanEnd(details),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Stack(
              children: [
                Column(
                  children: List.generate(widget.gridSize, (row) {
                    return Row(
                      children: List.generate(widget.gridSize, (col) {
                        final cell = _gameState.grid[row][col];
                        return GridCellWidget(
                          cell: cell,
                          size: cellSize,
                          isHighlighted: _isCellHighlighted(cell),
                        );
                      }),
                    );
                  }),
                ),
                CustomPaint(
                  size: Size.infinite,
                  painter: PathPainter(
                    path: _gameState.currentPath,
                    cellSize: cellSize,
                  ),
                ),
                if (_hintPoint != null)
                  Positioned(
                    left: _hintPoint!.col * cellSize,
                    top: _hintPoint!.row * cellSize,
                    child: Container(
                      width: cellSize,
                      height: cellSize,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                if (_successAnimationController.isAnimating)
                  Center(
                    child: ScaleTransition(
                      scale: _successAnimation,
                      child: Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: constraints.maxWidth * 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isCellHighlighted(GridCell cell) {
    if (_hintPoint != null && _hintPoint!.row == cell.row && _hintPoint!.col == cell.col) {
      return true;
    }
    if (_gameState.status == GameStatus.playing) {
      final nextNumber = _gameState.currentNumber;
      if (cell.number == nextNumber) return true;
    }
    return _gameState.currentPath.any((p) => p.row == cell.row && p.col == cell.col);
  }

  void showHint() {
    final hint = HintSystem.getNextHint(_gameState, _solutionPath);
    if (hint != null) {

      setState(() {
        _hintPoint = hint;
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _hintPoint = null;
          });
        }
      });
    }
  }

  void _onPanStart(DragStartDetails details, double cellSize) {
    if (_gameState.status == GameStatus.success) return;
    setState(() { _hintPoint = null; });
    final point = _pointFromOffset(details.localPosition, cellSize);
    if (point == null) return;

    final cell = _gameState.grid[point.row][point.col];
    if (cell.number == 1) {
      setState(() {
        _gameState = _gameState.copyWith(
          currentPath: [point],
          status: GameStatus.playing,
          currentNumber: 2,
        ).recordState(); // Record initial state
        _lastPoint = point;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details, double cellSize) {
    if (_gameState.status != GameStatus.playing) return;

    final currentGridPoint = _pointFromOffset(details.localPosition, cellSize);
    if (currentGridPoint == null) return;

    // If the user is trying to go back to the previous point (backtracking)
    if (_gameState.currentPath.length > 1 &&
        currentGridPoint.row == _gameState.currentPath[_gameState.currentPath.length - 2].row &&
        currentGridPoint.col == _gameState.currentPath[_gameState.currentPath.length - 2].col) {
      setState(() {
        _gameState = _gameState.copyWith(
          currentPath: List<PathPoint>.from(_gameState.currentPath)..removeLast(),
        );
        _lastPoint = _gameState.currentPath.last;
        // Update currentNumber if we backtrack over a numbered cell
        final cell = _gameState.grid[_lastPoint!.row][_lastPoint!.col];
        if (cell.number != null && cell.number! < _gameState.currentNumber) {
          _gameState = _gameState.copyWith(currentNumber: cell.number! + 1);
        }
        _gameState = _gameState.recordState(); // Record state after backtracking
      });
      _pathAnimationController.forward(from: 0.0);
      return;
    }

    // If the user is trying to move to the same point, do nothing
    if (currentGridPoint.row == _lastPoint!.row && currentGridPoint.col == _lastPoint!.col) {
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
          HapticFeedback.mediumImpact();
          nextNumber++;
        }

        setState(() {
          _gameState = _gameState.copyWith(
            currentPath: newPath,
            currentNumber: nextNumber,
          ).recordState(); // Record state after valid move
          _lastPoint = currentGridPoint;
        });
      } else {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_gameState.status != GameStatus.playing) return;

    if (PathValidator.checkWinCondition(_gameState)) {
      HapticFeedback.heavyImpact();
      setState(() {
        _gameState = _gameState.copyWith(status: GameStatus.success);
      });
      _successAnimationController.forward().whenComplete(() {
        _showGameDialog("Success!", "You solved the puzzle!");
      });
    } else {
      // If the game is not won, clear future history for new moves
      _gameState = _gameState.trimHistory(); // Use the new method
    }
  }

  PathPoint? _pointFromOffset(Offset offset, double cellSize) {
    final row = (offset.dy / cellSize).floor();
    final col = (offset.dx / cellSize).floor();

    if (row >= 0 && row < widget.gridSize && col >= 0 && col < widget.gridSize) {
      return PathPoint(row: row, col: col, order: _gameState.currentPath.length);
    }
    return null;
  }
  
  void _showGameDialog(String title, String content, [VoidCallback? onContinue]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onContinue != null) {
                onContinue();
              } else {
                initializeGame();
              }
            },
            child: Text(onContinue != null ? "Try Again" : "New Game"),
          ),
        ],
      ),
    );
  }
}
