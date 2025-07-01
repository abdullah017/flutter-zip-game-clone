
import 'package:flutter/material.dart';
import '../services/level_generator.dart'; // For Difficulty enum

class GameSettings extends ChangeNotifier {
  int _gridSize = 5;
  Difficulty _difficulty = Difficulty.medium;

  int get gridSize => _gridSize;
  Difficulty get difficulty => _difficulty;

  void setGridSize(int size) {
    if (_gridSize != size) {
      _gridSize = size;
      notifyListeners();
    }
  }

  void setDifficulty(Difficulty difficulty) {
    if (_difficulty != difficulty) {
      _difficulty = difficulty;
      notifyListeners();
    }
  }
}
