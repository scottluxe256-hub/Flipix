import 'dart:async';
import 'package:flutter/material.dart';
import 'lobby_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _opacityAnim;
  late Animation<double> _scaleAnim;
  bool _hasNavigated = false;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // Animasi Fade In dan Fade Out selama total 3 detik
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Fade In (0-35%), Hold (35-70%), Fade Out (70-100%)
    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_animController);

    // Efek skala lembut (zoom-in sangat halus)
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _animController.forward();

    // Otomatis pindah ke Lobby setelah 3 detik
    _navigationTimer = Timer(const Duration(milliseconds: 3000), () {
      _goToLobby();
    });
  }

  void _goToLobby() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _navigationTimer?.cancel();
    _animController.stop();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const LobbyScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background biru muda polos
      backgroundColor: const Color(0xFFBAE6FD),
      body: GestureDetector(
        onTap: _goToLobby, // Klik di mana saja untuk skip langsung ke lobby
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnim.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: _scaleAnim.value,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 220,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'FLIP CARD GAME',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: Color(0xFF0F172A),
                    shadows: [
                      Shadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}