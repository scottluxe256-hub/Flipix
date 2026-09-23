import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';
import '../components/card_widget.dart';
import '../components/glass_panel.dart';
import '../components/result_popup.dart';
import 'level_screen.dart';

class GameplayScreen extends StatefulWidget {
  final int level;
  const GameplayScreen({super.key, required this.level});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> with SingleTickerProviderStateMixin {
  late AnimationController _auroraController;
  late Animation<Color?> _colorAnim1;
  late Animation<Color?> _colorAnim2;

  List<String> _cards = [];
  List<bool> _isFlipped = [];
  List<bool> _isMatched = [];
  
  int _score = 0;
  late int _targetScore;
  late int _timeLeft;
  
  int _prepTime = 3;
  bool _isMemorizing = true;
  Timer? _timer;

  int? _firstSelectedIndex;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _targetScore = widget.level * 100;
    _timeLeft = 60 - (widget.level * 2); // Waktu makin sempit di level tinggi

    // Animasi Aurora Biru Soft
    _auroraController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _colorAnim1 = ColorTween(begin: const Color(0xFF0F2027), end: const Color(0xFF203A43)).animate(_auroraController);
    _colorAnim2 = ColorTween(begin: const Color(0xFF2C5364), end: const Color(0xFF0F2027)).animate(_auroraController);

    _setupCards();
    _startPrepTimer();
  }

  void _setupCards() {
    int pairsCount = min(widget.level + 2, 11); // Maksimal 11 pasang (sesuai jumlah assets card_1 sd card_11)
    List<String> selectedImages = [];
    for (int i = 1; i <= pairsCount; i++) {
      selectedImages.add('assets/images/card_$i.webp');
    }
    
    _cards = [...selectedImages, ...selectedImages];
    _cards.shuffle(Random());
    
    // Saat memorizing, semua kartu TERBUKA (isFlipped = true)
    _isFlipped = List.generate(_cards.length, (index) => true);
    _isMatched = List.generate(_cards.length, (index) => false);
  }

  void _startPrepTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_prepTime > 1) {
        setState(() => _prepTime--);
      } else {
        timer.cancel();
        _startGame();
      }
    });
  }

  void _startGame() {
    AudioManager.instance.playSfx('game-start.opus');
    setState(() {
      _isMemorizing = false;
      // Tutup semua kartu
      _isFlipped = List.generate(_cards.length, (index) => false);
    });
    
    // Mulai BGM ingame
    Future.delayed(const Duration(milliseconds: 500), () {
      AudioManager.instance.playBgm('ingame.m4a');
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _endGame(isWin: false);
      }
    });
  }

  void _onCardTap(int index) {
    if (_isMemorizing || _isProcessing || _isMatched[index] || _isFlipped[index]) return;

    AudioManager.instance.playSfx('flip.opus');
    setState(() => _isFlipped[index] = true);

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      _isProcessing = true;
      int first = _firstSelectedIndex!;
      int second = index;
      _firstSelectedIndex = null;

      if (_cards[first] == _cards[second]) {
        // Cocok (Benar)
        Future.delayed(const Duration(milliseconds: 300), () {
          AudioManager.instance.playSfx('benar.opus');
          setState(() {
            _isMatched[first] = true;
            _isMatched[second] = true;
            _score += 50;
            _isProcessing = false;
          });
          _checkWinCondition();
        });
      } else {
        // Salah
        Future.delayed(const Duration(milliseconds: 800), () {
          AudioManager.instance.playSfx('salah.opus');
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
    if (!_isMatched.contains(false)) { // Semua cocok
      if (_score >= _targetScore) {
        _endGame(isWin: true);
      } else {
        _endGame(isWin: false); // Semua terbuka tapi skor kurang
      }
    }
  }

  void _endGame({required bool isWin}) {
    _timer?.cancel();
    AudioManager.instance.stopBgm();
    
    if (isWin) {
      AudioManager.instance.playSfx('level-completed.opus');
      if (widget.level == highestLevelUnlockedGlobal && widget.level < 10) {
        highestLevelUnlockedGlobal++; // Buka level selanjutnya
      }
    } else {
      AudioManager.instance.playSfx('game-over.opus');
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResultPopup(
        isWin: isWin,
        score: _score,
        onNextOrRetry: () {
          AudioManager.instance.playSfx('click.opus');
          Navigator.pop(context); // Tutup popup
          if (isWin && widget.level < 10) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GameplayScreen(level: widget.level + 1)));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GameplayScreen(level: widget.level)));
          }
        },
        onExit: () {
          AudioManager.instance.playSfx('click.opus');
          Navigator.pop(context); // Tutup popup
          Navigator.pop(context); // Kembali ke level screen
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _auroraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sesuaikan jumlah kolom berdasarkan jumlah kartu agar muat di layar
    int crossAxisCount = _cards.length > 16 ? 8 : (_cards.length > 8 ? 6 : 4);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _auroraController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_colorAnim1.value!, _colorAnim2.value!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              // Panel Atas (Glassmorphism)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GlassPanel(
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          AudioManager.instance.playSfx('click.opus');
                          AudioManager.instance.stopBgm();
                          Navigator.pop(context);
                        },
                      ),
                      Text('Target: $_targetScore', style: const TextStyle(color: Colors.white, fontSize: 20)),
                      Text('Score: $_score', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('Time: 00:${_timeLeft.toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.redAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),

              // Area Game & Hitung Mundur
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          shrinkWrap: true,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.75, // Proporsi kartu standar
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
                    
                    // Angka besar hitung mundur 3, 2, 1
                    if (_isMemorizing)
                      Container(
                        color: Colors.black45, // Gelapkan sedikit agar angka menonjol
                        child: Center(
                          child: Text(
                            '$_prepTime',
                            style: const TextStyle(fontSize: 150, fontWeight: FontWeight.bold, color: Colors.white),
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