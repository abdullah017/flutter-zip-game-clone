import 'package:flutter/material.dart';
import 'package:flutter_zip_game/utils/constants.dart';
import '../models/path_point.dart';

class PathPainter extends CustomPainter {
  final List<PathPoint> path;
  final double cellSize;
  final Color pathColor;
  final double strokeWidth;

  PathPainter({
    required this.path,
    required this.cellSize,
    this.pathColor = AppColors.primaryColor,
    this.strokeWidth = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (path.isEmpty) return;

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.accentColor, AppColors.primaryColor], // Degrade renkleri
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth * 1.2; // Çizgi kalınlığını artır

    final uiPath = Path();
    final startPoint = _getPixelForPoint(path.first);
    uiPath.moveTo(startPoint.dx, startPoint.dy);

    for (int i = 1; i < path.length; i++) {
      final point = _getPixelForPoint(path[i]);
      uiPath.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(uiPath, paint);
  }

  Offset _getPixelForPoint(PathPoint point) {
    return Offset(
      point.col * cellSize + cellSize / 2,
      point.row * cellSize + cellSize / 2,
    );
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) {
    return oldDelegate.path != path || oldDelegate.cellSize != cellSize;
  }
}
