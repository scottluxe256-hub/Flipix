import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class GameState extends ChangeNotifier {
  GameState._();
  static final GameState instance = GameState._();

  int highestLevelUnlocked = 1;

  File _getSaveFile() {
    try {
      final appData = Platform.environment['APPDATA'];
      if (appData != null && Directory(appData).existsSync()) {
        final dir = Directory('$appData/FlipCardGame');
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
        return File('${dir.path}/save_progress.json');
      }
    } catch (_) {}
    return File('save_progress.json');
  }

  Future<void> init() async {
    try {
      final file = _getSaveFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content);
        if (data is Map && data['highestLevelUnlocked'] is int) {
          highestLevelUnlocked = (data['highestLevelUnlocked'] as int).clamp(1, 10);
        }
      }
    } catch (e) {
      debugPrint('Error loading game state: $e');
    }
    notifyListeners();
  }

  Future<void> unlockLevel(int level) async {
    if (level > highestLevelUnlocked && level <= 10) {
      highestLevelUnlocked = level;
      notifyListeners();
      await _save();
    }
  }

  Future<void> _save() async {
    try {
      final file = _getSaveFile();
      await file.writeAsString(jsonEncode({
        'highestLevelUnlocked': highestLevelUnlocked,
      }));
    } catch (e) {
      debugPrint('Error saving game state: $e');
    }
  }
}