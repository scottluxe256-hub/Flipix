import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager instance = AudioManager._internal();
  AudioManager._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool isBgmOn = true;
  bool isSfxOn = true;

  Future<void> init() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playBgm(String fileName) async {
    if (!isBgmOn) return;
    try {
      await _bgmPlayer.stop();
      await _bgmPlayer.play(AssetSource('audio/$fileName'));
    } catch (_) {}
  }

  void toggleBgm() {
    isBgmOn = !isBgmOn;
    if (isBgmOn) {
      _bgmPlayer.resume();
    } else {
      _bgmPlayer.pause();
    }
  }

  Future<void> playSfx(String fileName) async {
    if (!isSfxOn) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/$fileName'));
    } catch (_) {}
  }

  void toggleSfx() {
    isSfxOn = !isSfxOn;
  }
}