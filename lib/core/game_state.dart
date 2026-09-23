import 'package:flutter/material.dart';

class GameState extends ChangeNotifier {
  // Gunakan Singleton pattern agar mudah dipanggil tanpa Context
  GameState._();
  static final GameState instance = GameState._();

  int currentLevel = 1;
  int highestUnlockedLevel = 1; // Ubah nama variabel agar sesuai dengan LevelScreen
  
  int score = 0;
  int targetScore = 100;
  int timeLeft = 60;
  bool isPlaying = false;

  void unlockNextLevel() {
    if (currentLevel == highestUnlockedLevel && currentLevel < 10) {
      highestUnlockedLevel++;
      notifyListeners();
    }
  }

  // Ubah nama fungsi dari startLevel menjadi setLevel agar cocok dengan LevelScreen
  void setLevel(int level) {
    currentLevel = level;
    score = 0;
    targetScore = level * 100;
    timeLeft = 60 - (level * 2);
    isPlaying = true;
    notifyListeners();
  }

  void addScore(int points) {
    score += points;
    notifyListeners();
  }

  void setGameOver() {
    isPlaying = false;
    notifyListeners();
  }
}