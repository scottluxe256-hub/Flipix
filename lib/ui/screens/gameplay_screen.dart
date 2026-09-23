import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';
import '../../core/game_state.dart';
import '../components/card_widget.dart';
import '../components/glass_panel.dart';
import '../components/result_popup.dart'; // Pastikan memanggil ResultPopup

class GameplayScreen extends StatefulWidget {
  final int level;
  const GameplayScreen({super.key, required this.level});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  late List<String> _cards;
  late List<bool> _flipped;
  late List<bool> _matched;

  int? _previousIndex;
  bool _isBusy = false;
  int _pairsFound = 0;
  int _maxPairs = 6;
  int _score = 0;
  int _timeLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _setupLevel();
    _startTimer();
    AudioManager.instance.playBgm('bgm_ingame.m4a');
  }

  void _setupLevel() {
    _maxPairs = (widget.level + 2).clamp(3, 11);
    _timeLeft = 45 + (widget.level * 5);

    List<String> availableAssets = List.generate(
      11,
      (index) => 'assets/images/card_${index + 1}.webp',
    );
    availableAssets.shuffle();

    List<String> selectedAssets = availableAssets.take(_maxPairs).toList();
    _cards = [...selectedAssets, ...selectedAssets]..shuffle();

    _flipped = List.filled(_cards.length, false);
    _matched = List.filled(_cards.length, false);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() { _timeLeft--; });
      } else {
        _timer?.cancel();
        _showResult(isWin: false);
      }
    });
  }

  void _onCardTap(int index) async {
    if (_isBusy || _flipped[index] || _matched[index]) return;

    AudioManager.instance.playSfx('flip.m4a');

    setState(() { _flipped[index] = true; });

    if (_previousIndex == null) {
      _previousIndex = index;
    } else {
      _isBusy = true;
      int prev = _previousIndex!;

      if (_cards[prev] == _cards[index]) {
        AudioManager.instance.playSfx('match.m4a');
        setState(() {
          _matched[prev] = true;
          _matched[index] = true;
          _pairsFound++;
          _score += 50;
          _previousIndex = null;
          _isBusy = false;
        });

        if (_pairsFound == _maxPairs) {
          _timer?.cancel(); // Matikan timer sebelum proses apapun
          try {
            GameState.instance.unlockNextLevel();
          } catch (e) {
            debugPrint('Error unlocking level: $e');
          }
          _showResult(isWin: true);
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 700));
        setState(() {
          _flipped[prev] = false;
          _flipped[index] = false;
          _previousIndex = null;
          _isBusy = false;
        });
      }
    }
  }

  void _showResult({required bool isWin}) {
    AudioManager.instance.playSfx(isWin ? 'win.m4a' : 'gameover.m4a');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ResultPopup(
        isWin: isWin,
        score: _score + _timeLeft, // Tambahan bonus waktu
        onNextOrRetry: () {
          Navigator.pop(context);
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
          Navigator.pop(context);
          Navigator.pop(context); // Kembali ke menu
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade100, // Biru langit soft
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GlassPanel(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Level ${widget.level}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Time: ${_timeLeft}s', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Score: $_score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    // Menggunakan Wrap agar kartu selalu rata tengah (center alignment)
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(_cards.length, (index) {
                        return SizedBox(
                          width: 85,
                          height: 110,
                          child: CardWidget(
                            imagePath: _cards[index],
                            isFlipped: _flipped[index],
                            isMatched: _matched[index],
                            onTap: () => _onCardTap(index),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}