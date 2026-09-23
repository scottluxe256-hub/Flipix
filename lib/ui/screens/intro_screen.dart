import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'lobby_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  VideoPlayerController? _controller;
  bool _isFadingOut = false;
  bool _hasNavigated = false;
  bool _videoFailed = false;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _initVideo();

    // Otomatis pindah ke lobby setelah durasi intro (maks 6 detik)
    _fallbackTimer = Timer(const Duration(seconds: 6), () {
      _goToLobby();
    });
  }

  void _initVideo() {
    try {
      _controller = VideoPlayerController.asset('assets/video/x64.mp4')
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _controller?.play();
            _controller?.addListener(() {
              final val = _controller?.value;
              if (val != null && val.isInitialized && val.position >= val.duration) {
                _goToLobby();
              }
            });
          }
        }).catchError((error) {
          debugPrint('Info: Video player tidak dapat memutar video (kemungkinan codec atau backend Windows): $error');
          if (mounted) {
            setState(() {
              _videoFailed = true;
            });
          }
        });
    } catch (e) {
      debugPrint('Video controller init exception: $e');
      _videoFailed = true;
    }
  }

  void _goToLobby() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _fallbackTimer?.cancel();

    setState(() => _isFadingOut = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const LobbyScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _goToLobby, // Klik di mana saja untuk skip video
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Konten Video atau Splash Fallback
            AnimatedOpacity(
              opacity: _isFadingOut ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 500),
              child: Center(
                child: (_controller != null && _controller!.value.isInitialized)
                    ? AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      )
                    : _videoFailed
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                width: 200,
                                height: 200,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.style,
                                  size: 100,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'FLIP CARD GAME',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 3,
                                ),
                              ),
                            ],
                          )
                        : const CircularProgressIndicator(color: Colors.blueAccent),
              ),
            ),

            // Tombol Fallback SKIP Video di pojok kanan atas
            Positioned(
              top: 30,
              right: 30,
              child: SafeArea(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _goToLobby,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white38, width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'SKIP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.fast_forward_rounded, color: Colors.white, size: 18),
                        ],
                      ),
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