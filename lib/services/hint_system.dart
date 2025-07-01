
import '../models/game_state.dart';
import '../models/path_point.dart';

class HintSystem {
  // Bu fonksiyon, mevcut yola göre bir sonraki doğru adımı bulur.
  static PathPoint? getNextHint(GameState state, List<PathPoint> solutionPath) {
    if (state.currentPath.isEmpty) {
      // Eğer oyuncu henüz başlamadıysa, ilk adımı (1 numaralı hücre) göster.
      return solutionPath.first;
    }

    // Oyuncunun şu anki yolunun son noktasını al.
    final lastUserPoint = state.currentPath.last;

    // Çözüm yolunda, oyuncunun son noktasının indeksini bul.
    int currentIndexInSolution = -1;
    for (int i = 0; i < solutionPath.length; i++) {
      if (solutionPath[i].row == lastUserPoint.row && solutionPath[i].col == lastUserPoint.col) {
        currentIndexInSolution = i;
        break;
      }
    }

    // Eğer son nokta çözümde bulunursa ve bu son adım değilse, bir sonraki adımı döndür.
    if (currentIndexInSolution != -1 && currentIndexInSolution < solutionPath.length - 1) {
      // Bir sonraki adımı döndür.
      return solutionPath[currentIndexInSolution + 1];
    }

    // Eğer bir sonraki adım yoksa veya bir hata oluştuysa null döndür.
    return null;
  }
}
