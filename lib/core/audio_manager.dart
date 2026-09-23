import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  AudioManager._();
  static final AudioManager instance = AudioManager._();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  String? _currentBgmTrack;

  bool isBgmEnabled = true;
  bool isSfxEnabled = true;

  Future<void> init() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void playBgm(String filename) {
    _currentBgmTrack = filename;
    if (!isBgmEnabled) return;
    _bgmPlayer.play(AssetSource('audio/$filename'));
  }

  void stopBgm({bool clearTrack = false}) {
    _bgmPlayer.stop();
    if (clearTrack) {
      _currentBgmTrack = null;
    }
  }

  void playSfx(String filename) {
    if (!isSfxEnabled) return;
    // Menggunakan instance AudioPlayer terpisah agar SFX bisa overlap saat diklik cepat
    AudioPlayer().play(AssetSource('audio/$filename'));
  }

  void toggleBgm(bool value) {
    isBgmEnabled = value;
    if (!isBgmEnabled) {
      _bgmPlayer.stop();
    } else if (_currentBgmTrack != null) {
      _bgmPlayer.play(AssetSource('audio/$_currentBgmTrack'));
    }
  }

  void toggleSfx(bool value) {
    isSfxEnabled = value;
  }
}