import 'package:flutter/foundation.dart';

class GameState extends ChangeNotifier {
  static final GameState instance = GameState._internal();
  GameState._internal();

  int highestUnlockedLevel = 1;
  int currentLevel = 1;

  void unlockNextLevel() {
    if (currentLevel >= highestUnlockedLevel && highestUnlockedLevel < 10) {
      highestUnlockedLevel = currentLevel + 1;
      notifyListeners();
    }
  }

  void setLevel(int level) {
    currentLevel = level;
    notifyListeners();
  }
}