import 'package:flutter/material.dart';
import 'package:flutter_zip_game/utils/constants.dart';
import 'package:provider/provider.dart'; // Import provider
import 'models/game_settings.dart'; // Import GameSettings
import 'models/game_state_notifier.dart'; // Import GameStateNotifier
import 'widgets/game_ui.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GameSettings()),
        ChangeNotifierProxyProvider<GameSettings, GameStateNotifier>(
          create: (context) => GameStateNotifier(
            gridSize: Provider.of<GameSettings>(context, listen: false).gridSize,
            difficulty: Provider.of<GameSettings>(context, listen: false).difficulty,
          ),
          update: (context, gameSettings, gameStateNotifier) {
            // Reinitialize game when settings change
            gameStateNotifier!.initializeGame(gameSettings.gridSize, gameSettings.difficulty);
            return gameStateNotifier;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Zip Game',
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.backgroundColor, // Use the new background color
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.backgroundColor, // Match app bar with background
          foregroundColor: AppColors.textColor,
          elevation: 0,
          centerTitle: true, // Center app bar title for a cleaner look
        ),
        textTheme: TextTheme(
          bodyMedium: AppTextStyles.body,
          titleLarge: AppTextStyles.title,
        ).apply(bodyColor: AppColors.textColor, displayColor: AppColors.textColor), // Ensure all text uses textColor
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Add a subtle splash color for taps
        splashColor: AppColors.accentColor.withOpacity(0.3),
        highlightColor: Colors.transparent, // Remove default highlight
      ),
      debugShowCheckedModeBanner: false,
      home: const GameUI(),
    );
  }
}