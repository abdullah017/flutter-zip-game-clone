
import 'dart:math';
import 'package:flutter/foundation.dart';

import '../models/level_data.dart';
import '../models/grid_cell.dart';
import '../models/path_point.dart';

enum Difficulty {
  easy,
  medium,
  hard,
}

class LevelGenerator {
  static LevelData generateLevel(int gridSize, Difficulty difficulty) {
    // 1. Hamiltonian path oluştur
    final path = _generateHamiltonianPath(gridSize);
    if (path.isEmpty) {
      if (kDebugMode) {
        print("LevelGenerator: Hamiltonian path generation failed for grid size $gridSize");
      }
      return LevelData(grid: [], gridSize: gridSize, totalNumbers: 0, solutionPath: []);
    }

    // 2. Zorluk seviyesine göre checkpoint sayısını belirle
    int numberOfCheckpoints = (gridSize * gridSize / 5).toInt().clamp(4, 12);

    // Adjust based on difficulty
    switch (difficulty) {
      case Difficulty.easy:
        numberOfCheckpoints = (numberOfCheckpoints * 0.8).toInt().clamp(4, 12);
        break;
      case Difficulty.medium:
        // Use calculated value
        break;
      case Difficulty.hard:
        numberOfCheckpoints = (numberOfCheckpoints * 1.2).toInt().clamp(4, 12);
        break;
    }

    // 3. Checkpoint'leri seç
    final checkpointIndices = _selectCheckpoints(path, numberOfCheckpoints);

    // 4. Grid'i oluştur ve numaraları yerleştir
    final grid = List.generate(
        gridSize,
        (row) => List.generate(
            gridSize, (col) => GridCell(row: row, col: col)));

    int numberCounter = 1;
    final Map<int, PathPoint> numberedPoints = {};

    for (int i = 0; i < path.length; i++) {
      if (checkpointIndices.contains(i)) {
        final point = path[i];
        grid[point.row][point.col] = grid[point.row][point.col]
            .copyWith(number: numberCounter);
        numberedPoints[numberCounter] = point;
        numberCounter++;
      }
    }

    return LevelData(
      grid: grid,
      gridSize: gridSize,
      totalNumbers: numberCounter - 1,
      solutionPath: path,
    );
  }

  static List<PathPoint> _generateHamiltonianPath(int gridSize) {
    final random = Random();
    const int maxAttempts = 10; // Try a few times

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final startRow = random.nextInt(gridSize);
      final startCol = random.nextInt(gridSize);

      final path = <PathPoint>[];
      var visited = List.generate(gridSize, (_) => List.generate(gridSize, (_) => false));

      bool solve(int r, int c) {
        path.add(PathPoint(row: r, col: c, order: path.length));
        visited[r][c] = true;

        if (path.length == gridSize * gridSize) {
          return true;
        }

        final neighbors = [
          [r - 1, c],
          [r + 1, c],
          [r, c - 1],
          [r, c + 1]
        ]..shuffle(random);

        for (var n in neighbors) {
          final newR = n[0];
          final newC = n[1];

          if (newR >= 0 &&
              newR < gridSize &&
              newC >= 0 &&
              newC < gridSize &&
              !visited[newR][newC]) {
            if (solve(newR, newC)) {
              return true;
            }
          }
        }

        // Backtrack
        path.removeLast();
        visited[r][c] = false;
        return false;
      }

      if (solve(startRow, startCol)) {
        return path;
      }
    }

    if (kDebugMode) {
      print("LevelGenerator: Failed to generate Hamiltonian path after $maxAttempts attempts.");
    }
    return []; // Still failed after multiple attempts
  }

  static List<int> _selectCheckpoints(List<PathPoint> path, int count) {
    final indices = <int>{};
    final pathLength = path.length;

    // Ensure first and last points are always checkpoints
    indices.add(0);
    if (pathLength > 1) {
      indices.add(pathLength - 1);
    }

    // Distribute remaining checkpoints more evenly
    final random = Random();
    final step = pathLength / (count - 1); // Calculate step for even distribution

    for (int i = 1; i < count - 1; i++) {
      int index = (i * step).toInt();
      // Add some randomness around the calculated step to make it less predictable
      index = (index + random.nextInt(step.toInt().clamp(1, pathLength ~/ 4)) - (step.toInt().clamp(1, pathLength ~/ 4) ~/ 2)).clamp(1, pathLength - 2);
      indices.add(index);
    }

    final sortedIndices = indices.toList()..sort();
    return sortedIndices;
  }
}
