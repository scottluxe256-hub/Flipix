import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  AudioManager._();
  static final AudioManager instance = AudioManager._();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool isBgmEnabled = true;
  bool isSfxEnabled = true;

  Future<void> init() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void playBgm(String filename) {
    if (!isBgmEnabled) return;
    _bgmPlayer.play(AssetSource('audio/$filename'));
  }

  void stopBgm() {
    _bgmPlayer.stop();
  }

  void playSfx(String filename) {
    if (!isSfxEnabled) return;
    // Menggunakan source terpisah agar SFX bisa overlap jika diklik cepat
    AudioPlayer().play(AssetSource('audio/$filename'));
  }

  void toggleBgm(bool value) {
    isBgmEnabled = value;
    if (!isBgmEnabled) stopBgm();
    // Logic untuk resume BGM bisa ditambahkan sesuai state aktif
  }

  void toggleSfx(bool value) {
    isSfxEnabled = value;
  }
}