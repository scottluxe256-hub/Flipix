import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';
import '../../core/game_state.dart';
import '../components/card_widget.dart';
import '../components/glass_panel.dart';
import '../components/result_popup.dart';
import 'lobby_screen.dart';

class GameplayScreen extends StatefulWidget {
  final int level;
  const GameplayScreen({super.key, required this.level});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  List<String> _cards = [];
  List<bool> _isFlipped = [];
  List<bool> _isMatched = [];

  int _score = 0;
  late int _timeLeft;

  int _prepTime = 3;
  bool _isMemorizing = true;
  Timer? _timer;

  int? _firstSelectedIndex;
  bool _isProcessing = false;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    // Waktu mulai dari 60 detik, berkurang sedikit di level tinggi
    _timeLeft = max(30, 60 - (widget.level - 1) * 3);

    _setupCards();
    _startPrepTimer();
  }

  void _setupCards() {
    final int pairsCount = min(widget.level + 2, 11);
    final List<String> selectedImages = [];
    for (int i = 1; i <= pairsCount; i++) {
      selectedImages.add('assets/images/card_$i.webp');
    }

    _cards = [...selectedImages, ...selectedImages];
    _cards.shuffle(Random());

    // Saat memorizing di awal, semua kartu TERBUKA
    _isFlipped = List.generate(_cards.length, (index) => true);
    _isMatched = List.generate(_cards.length, (index) => false);
  }

  void _startPrepTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_prepTime > 1) {
        if (mounted) setState(() => _prepTime--);
      } else {
        timer.cancel();
        _startGame();
      }
    });
  }

  void _startGame() {
    AudioManager.instance.playSfx('game-start.m4a');
    if (!mounted) return;

    setState(() {
      _isMemorizing = false;
      // Tutup semua kartu saat game mulai
      _isFlipped = List.generate(_cards.length, (index) => false);
    });

    // Mulai BGM ingame
    Future.delayed(const Duration(milliseconds: 300), () {
      AudioManager.instance.playBgm('ingame.m4a');
    });

    // Timer waktu game (Fokus murni ke waktu sebagai penentu menang/kalah)
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 1) {
        if (mounted) setState(() => _timeLeft--);
      } else {
        timer.cancel();
        if (mounted) {
          setState(() => _timeLeft = 0);
          _endGame(isWin: false);
        }
      }
    });
  }

  void _onCardTap(int index) {
    if (_isMemorizing || _isProcessing || _isGameOver || _isMatched[index] || _isFlipped[index]) return;

    AudioManager.instance.playSfx('flip.m4a');
    setState(() => _isFlipped[index] = true);

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      _isProcessing = true;
      final int first = _firstSelectedIndex!;
      final int second = index;
      _firstSelectedIndex = null;

      if (_cards[first] == _cards[second]) {
        // Pasangan Cocok (Benar)
        Future.delayed(const Duration(milliseconds: 250), () {
          if (!mounted) return;
          AudioManager.instance.playSfx('benar.m4a');
          setState(() {
            _isMatched[first] = true;
            _isMatched[second] = true;
            _score += 50; // Skor bertambah konsisten (sama persis dengan yang tampil di dialog)
            _isProcessing = false;
          });
          _checkWinCondition();
        });
      } else {
        // Salah: Balik kembali tanpa mengurangi nyawa
        Future.delayed(const Duration(milliseconds: 700), () {
          if (!mounted) return;
          AudioManager.instance.playSfx('salah.m4a');
          setState(() {
            _isFlipped[first] = false;
            _isFlipped[second] = false;
            _isProcessing = false;
          });
        });
      }
    }
  }

  void _checkWinCondition() {
    // Menang jika SEMUA kartu berhasil dicocokkan sebelum waktu habis
    // Skor tidak dimodifikasi lagi agar sama persis dengan indikator atas
    if (!_isMatched.contains(false)) {
      _endGame(isWin: true);
    }
  }

  void _endGame({required bool isWin}) {
    if (_isGameOver) return;
    _isGameOver = true;
    _timer?.cancel();
    AudioManager.instance.stopBgm();

    if (isWin) {
      AudioManager.instance.playSfx('level-completed.m4a');
      // Buka level berikutnya secara persisten
      GameState.instance.unlockLevel(widget.level + 1);
    } else {
      AudioManager.instance.playSfx('game-over.m4a');
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResultPopup(
        isWin: isWin,
        score: _score, // Skor sama persis dengan indikator atas
        onNextOrRetry: () {
          AudioManager.instance.playSfx('click.m4a');
          Navigator.pop(context); // Tutup dialog
          if (isWin && widget.level < 10) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => GameplayScreen(level: widget.level + 1)),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => GameplayScreen(level: widget.level)),
            );
          }
        },
        onExit: () {
          AudioManager.instance.playSfx('click.m4a');
          AudioManager.instance.stopBgm();
          // Keluar dari ingame langsung mengarah ke Lobby dan memutar output.m4a
          AudioManager.instance.playBgm('output.m4a');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LobbyScreen()),
            (route) => false,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    AudioManager.instance.stopBgm();
    super.dispose();
  }

  int _getCrossAxisCount(int totalCards) {
    // Melebar ke samping kiri dan kanan (maksimal 2 baris agar tidak terus ke bawah)
    return (totalCards / 2).ceil();
  }

  double _getCardSpacing(int totalCards) {
    if (totalCards <= 8) return 14.0;
    if (totalCards <= 12) return 10.0;
    if (totalCards <= 16) return 8.0;
    return 6.0;
  }

  double _getMaxGridWidth(int totalCards) {
    // Sesuaikan lebar container agar kartu semakin banyak ukuran mengecil secara proporsional
    if (totalCards <= 6) return 480;
    if (totalCards <= 8) return 600;
    if (totalCards <= 10) return 720;
    if (totalCards <= 12) return 840;
    if (totalCards <= 14) return 940;
    if (totalCards <= 16) return 1040;
    if (totalCards <= 18) return 1120;
    return 1200;
  }

  @override
  Widget build(BuildContext context) {
    final int crossAxisCount = _getCrossAxisCount(_cards.length);
    final double maxGridWidth = _getMaxGridWidth(_cards.length);
    final double spacing = _getCardSpacing(_cards.length);

    return Scaffold(
      body: Container(
        // Background Biru Langit Soft (Soft Sky Blue) khusus ingame
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE0F2FE), // Biru langit sangat lembut (atas)
              Color(0xFFBAE6FD), // Biru langit cerah lembut (bawah)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Panel Atas Glassmorphism
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: GlassPanel(
                  height: 75,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A), size: 28),
                        tooltip: 'Kembali',
                        onPressed: () {
                          AudioManager.instance.playSfx('click.m4a');
                          AudioManager.instance.stopBgm();
                          AudioManager.instance.playBgm('output.m4a');
                          Navigator.pop(context);
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Level ${widget.level}',
                          style: const TextStyle(
                            color: Color(0xFF0369A1),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Score: $_score',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, color: Color(0xFFDC2626), size: 26),
                          const SizedBox(width: 6),
                          Text(
                            '00:${_timeLeft.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Color(0xFFDC2626),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Area Game & Kartu di-align Center
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Grid Kartu diposisikan di tengah, melebar ke samping kiri-kanan & mengecil proporsional
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            alignment: Alignment.center,
                            constraints: BoxConstraints(maxWidth: maxGridWidth),
                            child: GridView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: spacing,
                                mainAxisSpacing: spacing,
                                childAspectRatio: 0.72,
                              ),
                              itemCount: _cards.length,
                              itemBuilder: (context, index) {
                                return CardWidget(
                                  isFlipped: _isFlipped[index],
                                  imagePath: _cards[index],
                                  onTap: () => _onCardTap(index),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Hitung mundur persiapan (3, 2, 1)
                    if (_isMemorizing)
                      Container(
                        color: Colors.black38,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'HAFALKAN KARTU!',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(color: Colors.black54, blurRadius: 8),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '$_prepTime',
                                style: const TextStyle(
                                  fontSize: 130,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(color: Colors.black45, blurRadius: 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}