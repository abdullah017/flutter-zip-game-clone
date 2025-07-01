
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_settings.dart';
import '../services/level_generator.dart'; // For Difficulty enum
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameSettings = Provider.of<GameSettings>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: AppTextStyles.title.copyWith(fontSize: 22)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Grid Size', style: AppTextStyles.subtitle),
            Slider(
              value: gameSettings.gridSize.toDouble(),
              min: 4,
              max: 8,
              divisions: 4,
              label: gameSettings.gridSize.toString(),
              onChanged: (value) {
                gameSettings.setGridSize(value.toInt());
              },
              activeColor: AppColors.primaryColor,
              inactiveColor: AppColors.gridBorderColor,
            ),
            const SizedBox(height: 20),
            Text('Difficulty', style: AppTextStyles.subtitle),
            Column(
              children: Difficulty.values.map((difficulty) {
                return RadioListTile<Difficulty>(
                  title: Text(difficulty.toString().split('.').last.toUpperCase(), style: AppTextStyles.body),
                  value: difficulty,
                  groupValue: gameSettings.difficulty,
                  onChanged: (value) {
                    if (value != null) {
                      gameSettings.setDifficulty(value);
                    }
                  },
                  activeColor: AppColors.primaryColor,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
