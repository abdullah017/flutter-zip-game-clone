
import '../models/game_state.dart';
import '../models/grid_cell.dart';
import '../models/path_point.dart';

class PathValidator {
  // Bu metod, her adımda yolun genel geçerliliğini kontrol eder.
  static bool isValidPath(List<PathPoint> path, List<List<GridCell>> grid) {
    if (path.length < 2) return true; // Tek nokta her zaman geçerlidir

    // 1. Kesişim Kontrolü (Self-Intersection)
    final visitedPoints = <String>{};
    for (final point in path) {
      final pointId = '${point.row}-${point.col}';
      if (visitedPoints.contains(pointId)) {
        return false; // Kesişim var
      }
      visitedPoints.add(pointId);
    }

    // 2. Sıralı Numaraları Kontrol Et
    int expectedNumber = 1;
    for (final point in path) {
      final cell = grid[point.row][point.col];
      if (cell.number != null) {
        if (cell.number == expectedNumber) {
          expectedNumber++;
        } else {
          // Eğer yol üzerindeki bir sayı, beklenen sırada değilse
          // ve bu sayı daha sonraki bir sayıysa, bu geçersiz bir durumdur.
          // Örn: 1'den 3'e atlamak.
          if (cell.number! > expectedNumber) return false;
        }
      }
    }

    // 3. Sadece Komşu Hücrelere Hareket Kontrolü
    for (int i = 1; i < path.length; i++) {
      final prev = path[i - 1];
      final curr = path[i];
      final dx = (curr.col - prev.col).abs();
      final dy = (curr.row - prev.row).abs();
      // Sadece dikey veya yatay hareket (Manhattan mesafesi 1 olmalı)
      if (dx + dy != 1) {
        return false;
      }
    }

    return true;
  }

  // Bu metod, oyunun kazanma koşulunu kontrol eder.
  static bool checkWinCondition(GameState state) {
    final gridSize = state.gridSize;
    final totalCells = gridSize * gridSize;

    // 1. Tüm hücreler ziyaret edildi mi?
    if (state.currentPath.length != totalCells) {
      return false;
    }

    // 2. Tüm numaralar doğru sırada ziyaret edildi mi?
    int lastVisitedNumber = 0;
    for (final point in state.currentPath) {
      final cell = state.grid[point.row][point.col];
      if (cell.number != null) {
        if (cell.number == lastVisitedNumber + 1) {
          lastVisitedNumber = cell.number!;
        } else {
          return false; // Numaralar sırada değil
        }
      }
    }

    // 3. Toplam numara sayısına ulaşıldı mı?
    if (lastVisitedNumber != state.totalNumbers) {
      return false;
    }

    // Tüm koşullar sağlandıysa, oyun kazanılmıştır.
    return true;
  }
}
