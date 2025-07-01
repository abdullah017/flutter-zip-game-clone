
import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF6A5ACD); // Daha zengin mor tonu
  static const Color accentColor = Color(0xFF48D1CC); // Canlı turkuaz
  static const Color backgroundColor = Color(0xFF212121); // Koyu gri/siyah
  static const Color gridCellColor = Color(0xFF303030); // Daha açık koyu gri
  static const Color gridBorderColor = Color(0xFF424242); // Orta gri
  static const Color textColor = Color(0xFFE0E0E0); // Açık gri
  static const Color highlightColor = Color(0xFFFFA726); // Daha sıcak turuncu
  static const Color successColor = Color(0xFF66BB6A); // Yumuşak yeşil
  static const Color errorColor = Color(0xFFEF5350); // Yumuşak kırmızı
}

class AppTextStyles {
  static const TextStyle title = TextStyle(
    fontFamily: 'Roboto', // Varsayılan font, isterseniz Google Fonts ekleyebilirsiniz
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textColor,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    color: AppColors.textColor,
  );

  static const TextStyle number = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
