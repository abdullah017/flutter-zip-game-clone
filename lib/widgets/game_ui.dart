
import 'package:flutter/material.dart';
import 'package:flutter_zip_game/utils/constants.dart';
import '../services/level_generator.dart';
import 'game_grid.dart';

class GameUI extends StatefulWidget {
  const GameUI({Key? key}) : super(key: key);

  @override
  _GameUIState createState() => _GameUIState();
}

class _GameUIState extends State<GameUI> {
  final GlobalKey<GameGridState> _gridKey = GlobalKey<GameGridState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LinkedIn Zip Clone', style: AppTextStyles.title.copyWith(fontSize: 22)),
        // backgroundColor: Colors.blue, // Handled by theme
        // elevation: 0, // Handled by theme
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Connect the numbers and fill the grid!',
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final isLargeScreen = screenWidth > 600; // Define what constitutes a "large screen"
                      final double adaptivePadding = isLargeScreen ? 40.0 : 16.0;
                      final double adaptiveBorderRadius = isLargeScreen ? 20.0 : 12.0;
                      final double adaptiveBlurRadius = isLargeScreen ? 30.0 : 20.0;
                      final double adaptiveSpreadRadius = isLargeScreen ? 12.0 : 8.0;

                      return SizedBox(
                        width: isLargeScreen ? 600 : screenWidth - (adaptivePadding * 2), // Max width for large screens
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.gridBorderColor, width: 2),
                            borderRadius: BorderRadius.circular(adaptiveBorderRadius),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: adaptiveBlurRadius,
                                spreadRadius: adaptiveSpreadRadius,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: GameGrid(
                            key: _gridKey,
                            gridSize: 5,
                            difficulty: Difficulty.medium,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8.0, // Horizontal space between buttons
                runSpacing: 8.0, // Vertical space between rows of buttons
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _gridKey.currentState?.undo();
                    },
                    icon: const Icon(Icons.undo, size: 24),
                    label: const Text('Undo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gridBorderColor, // Button background color
                      foregroundColor: AppColors.textColor, // Button text/icon color
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                      elevation: 5, // Add elevation for a modern look
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _gridKey.currentState?.redo();
                    },
                    icon: const Icon(Icons.redo, size: 24),
                    label: const Text('Redo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gridBorderColor, // Button background color
                      foregroundColor: AppColors.textColor, // Button text/icon color
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                      elevation: 5, // Add elevation for a modern look
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _gridKey.currentState?.initializeGame();
                    },
                    icon: const Icon(Icons.refresh, size: 24),
                    label: const Text('New Game'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor, // Button background color
                      foregroundColor: AppColors.textColor, // Button text/icon color
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                      elevation: 5, // Add elevation for a modern look
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _gridKey.currentState?.showHint();
                    },
                    icon: const Icon(Icons.lightbulb_outline, size: 24),
                    label: const Text('Hint'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentColor, // Button background color
                      foregroundColor: AppColors.backgroundColor, // Button text/icon color
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                      elevation: 5, // Add elevation for a modern look
                    ),
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
