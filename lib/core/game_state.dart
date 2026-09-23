import 'package:flutter/material.dart';

class GameState extends ChangeNotifier {
  int currentLevel = 1;
  int highestLevelUnlocked = 1;
  
  int score = 0;
  int targetScore = 100;
  int timeLeft = 60;
  bool isPlaying = false;

  void unlockNextLevel() {
    if (currentLevel == highestLevelUnlocked && currentLevel < 10) {
      highestLevelUnlocked++;
      notifyListeners();
    }
  }

  void startLevel(int level) {
    currentLevel = level;
    score = 0;
    targetScore = level * 100; // Contoh kalkulasi target
    timeLeft = 60 - (level * 2); // Semakin tinggi level, waktu makin sedikit
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