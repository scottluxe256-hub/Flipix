import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  AudioManager._();
  static final AudioManager instance = AudioManager._();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  String? _currentBgmTrack;

  // Pool AudioPlayer yang digunakan kembali untuk mencegah memory leak & CPU spike
  final List<AudioPlayer> _sfxPool = [];
  int _sfxPoolIndex = 0;
  static const int _sfxPoolSize = 4;

  bool isBgmEnabled = true;
  bool isSfxEnabled = true;

  String? get currentBgmTrack => _currentBgmTrack;

  Future<void> init() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    // Inisialisasi pool SFX tetap sekali saja
    for (int i = 0; i < _sfxPoolSize; i++) {
      final player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.stop);
      _sfxPool.add(player);
    }
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
    if (_sfxPool.isEmpty) {
      // Fallback jika belum terinit
      AudioPlayer().play(AssetSource('audio/$filename'));
      return;
    }
    // Menggunakan kembali player dari pool (tidak spawn C++ audio thread baru setiap klik)
    final player = _sfxPool[_sfxPoolIndex];
    _sfxPoolIndex = (_sfxPoolIndex + 1) % _sfxPoolSize;
    player.stop();
    player.play(AssetSource('audio/$filename'));
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