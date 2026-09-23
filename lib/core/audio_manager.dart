import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart'; // Untuk debugPrint

class AudioManager {
  AudioManager._();
  static final AudioManager instance = AudioManager._();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  // Tidak perlu _sfxPlayer global jika setiap SFX membuat instance baru

  bool isBgmEnabled = true;
  bool isSfxEnabled = true;
  String _currentBgm = ''; // Menyimpan nama BGM terakhir yang diputar

  Future<void> init() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void playBgm(String filename) async {
    _currentBgm = filename; // Simpan status BGM saat ini
    if (!isBgmEnabled) return;
    try {
      await _bgmPlayer.play(AssetSource('audio/$filename'));
    } catch (e) {
      debugPrint('Error playing BGM: $e');
    }
  }

  void stopBgm() async {
    await _bgmPlayer.stop();
  }
  
  void pauseBgm() async {
      await _bgmPlayer.pause();
  }
  
  void resumeBgm() async {
       if (isBgmEnabled) {
          await _bgmPlayer.resume();
       }
  }

  void playSfx(String filename) async {
    if (!isSfxEnabled) return;
    try {
      // Instance baru agar bisa overlap tanpa memotong suara sebelumnya
      final player = AudioPlayer();
      await player.play(AssetSource('audio/$filename'));
      player.onPlayerComplete.listen((_) => player.dispose()); // Bersihkan memori setelah selesai
    } catch (e) {
      debugPrint('Error playing SFX: $e');
    }
  }

  void toggleBgm(bool value) {
    isBgmEnabled = value;
    if (isBgmEnabled) {
      // Jika dihidupkan, putar ulang BGM terakhir dari awal
      if (_currentBgm.isNotEmpty) {
        playBgm(_currentBgm);
      }
    } else {
      stopBgm();
    }
  }

  void toggleSfx(bool value) {
    isSfxEnabled = value;
  }
  
  // Getter agar sesuai dengan kode di LobbyScreen
  bool get isBgmOn => isBgmEnabled;
}