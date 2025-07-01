import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zip_game/models/game_settings.dart';
import 'package:flutter_zip_game/models/game_state_notifier.dart';
import 'package:flutter_zip_game/utils/constants.dart';
import 'package:provider/provider.dart';
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

  const GameGrid({Key? key, required this.gridSize, required this.difficulty})
    : super(key: key);

  @override
  GameGridState createState() => GameGridState();
}

class GameGridState extends State<GameGrid> with TickerProviderStateMixin {
  late AnimationController _pathAnimationController;
  late AnimationController _successAnimationController;
  late Animation<double> _successAnimation;
  late AnimationController _gridEnterAnimationController; // New controller for grid entry
  late Animation<double> _gridEnterAnimation; // New animation for grid entry

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
    _gridEnterAnimationController = AnimationController( // Initialize new controller
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Slightly longer duration for more impact
    );
    _gridEnterAnimation = CurvedAnimation( // Initialize new animation
      parent: _gridEnterAnimationController,
      curve: Curves.elasticOut, // Changed curve for a more dynamic feel
    );
    _gridEnterAnimationController.forward(from: 0.0); // Start grid entry animation
  }

  @override
  void dispose() {
    _pathAnimationController.dispose();
    _successAnimationController.dispose();
    _gridEnterAnimationController.dispose(); // Dispose new controller
    super.dispose();
  }

  // Helper to get pixel coordinates from grid point
  Offset _getPixelForPoint(PathPoint point, double cellSize) {
    return Offset(
      point.col * cellSize + cellSize / 2,
      point.row * cellSize + cellSize / 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateNotifier>(
      builder: (context, gameStateNotifier, child) {
        final gameState = gameStateNotifier.gameState;
        
        return LayoutBuilder(
          builder: (context, constraints) {
            final double cellSize = constraints.maxWidth / gameState.gridSize; // Use constraints.maxWidth

            return GestureDetector(
              onPanStart: (details) => gameStateNotifier.onPanStart(details.localPosition, cellSize),
              onPanUpdate: (details) => gameStateNotifier.onPanUpdate(details.localPosition, cellSize),
              onPanEnd: (details) {
                final status = gameStateNotifier.onPanEnd();
                if (status == GameStatus.success) {
                  HapticFeedback.heavyImpact();
                  _successAnimationController.forward().whenComplete(() {
                    _showGameDialog("Success!", "You solved the puzzle!");
                  });
                }
              },
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Stack(
                  children: [
                    Column(
                      children: List.generate(gameState.gridSize, (row) { // Use gameState.gridSize
                        return Row(
                          children: List.generate(gameState.gridSize, (col) { // Use gameState.gridSize
                            final cell = gameState.grid[row][col]; // Use gameState.grid
                            return AnimatedBuilder(
                              animation: _gridEnterAnimationController,
                              builder: (context, child) {
                                final cellIndex = row * gameState.gridSize + col; // Use gameState.gridSize
                                final totalCells = gameState.gridSize * gameState.gridSize; // Use gameState.gridSize

                                // Define the total duration for the staggered effect
                                const staggerFactor = 0.8; // How much of the total animation duration is used for staggering
                                final totalStaggerDuration = _gridEnterAnimationController.duration!.inMilliseconds * staggerFactor;

                                // Calculate the start delay for this specific cell
                                final cellDelay = (cellIndex / totalCells) * totalStaggerDuration;

                                // Define the duration for each individual cell's animation
                                const cellAnimationDuration = 500; // milliseconds

                                // Calculate the normalized start and end times for the Interval
                                final begin = cellDelay / _gridEnterAnimationController.duration!.inMilliseconds;
                                final end = (cellDelay + cellAnimationDuration) / _gridEnterAnimationController.duration!.inMilliseconds;

                                // Ensure end does not exceed 1.0
                                final clampedEnd = end.clamp(0.0, 1.0);

                                final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                                  CurvedAnimation(
                                    parent: _gridEnterAnimationController,
                                    curve: Interval(
                                      begin,
                                      clampedEnd,
                                      curve: Curves.elasticOut, // Apply elasticOut to each cell's animation
                                    ),
                                  ),
                                );

                                final clampedAnimationValue = animation.value.clamp(0.0, 1.0);

                                return Transform.scale(
                                  scale: clampedAnimationValue,
                                  child: Opacity(
                                    opacity: clampedAnimationValue,
                                    child: GridCellWidget(
                                      cell: cell,
                                      size: cellSize,
                                      isHighlighted: _isCellHighlighted(cell, gameStateNotifier), // Pass notifier
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        );
                      }),
                    ),
                    CustomPaint(
                      size: Size.infinite,
                      painter: PathPainter(
                        path: gameState.currentPath, // Use gameState.currentPath
                        cellSize: cellSize,
                      ),
                    ),
                    if (gameStateNotifier.hintPoint != null) // Use notifier's hintPoint
                      Positioned(
                        left: gameStateNotifier.hintPoint!.col * cellSize,
                        top: gameStateNotifier.hintPoint!.row * cellSize,
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
      },
    );
  }

  bool _isCellHighlighted(GridCell cell, GameStateNotifier gameStateNotifier) {
    final gameState = gameStateNotifier.gameState;
    if (gameStateNotifier.hintPoint != null && gameStateNotifier.hintPoint!.row == cell.row && gameStateNotifier.hintPoint!.col == cell.col) {
      return true;
    }
    if (gameState.status == GameStatus.playing) {
      final nextNumber = gameState.currentNumber;
      if (cell.number == nextNumber) return true;
    }
    return gameState.currentPath.any((p) => p.row == cell.row && p.col == cell.col);
  }

  void _showGameDialog(String title, String content) {
    final isSuccess = title == "Success!";
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor, // Use game's background color
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: isSuccess ? AppColors.successColor : AppColors.errorColor,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.check_circle_outline : Icons.cancel_outlined,
                color: isSuccess ? AppColors.successColor : AppColors.errorColor,
                size: 80,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: AppTextStyles.title.copyWith(
                  color: isSuccess ? AppColors.successColor : AppColors.errorColor,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                content,
                style: AppTextStyles.body.copyWith(color: AppColors.textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Reinitialize game using GameStateNotifier
                      Provider.of<GameStateNotifier>(context, listen: false).initializeGame(
                        Provider.of<GameSettings>(context, listen: false).gridSize,
                        Provider.of<GameSettings>(context, listen: false).difficulty,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSuccess ? AppColors.successColor : AppColors.errorColor,
                      foregroundColor: AppColors.backgroundColor,
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                    ),
                    child: Text(isSuccess ? "New Game" : "Try Again"),
                  ),
                  if (isSuccess) // Only show next level button on success
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // TODO: Implement logic to load next level
                        Provider.of<GameStateNotifier>(context, listen: false).initializeGame(
                          Provider.of<GameSettings>(context, listen: false).gridSize,
                          Provider.of<GameSettings>(context, listen: false).difficulty,
                        ); // For now, just start a new game
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.textColor,
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                      ),
                      child: const Text("Next Level"),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}