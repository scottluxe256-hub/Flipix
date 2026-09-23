import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'lobby_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late VideoPlayerController _controller;
  bool _isFadingOut = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video/x64.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    // Pindah ke lobby setelah 7 detik (atau saat video selesai) dengan fade out
    Future.delayed(const Duration(seconds: 7), () {
      if (mounted) {
        setState(() => _isFadingOut = true);
        Future.delayed(const Duration(milliseconds: 800), () {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 800),
              pageBuilder: (_, __, ___) => const LobbyScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedOpacity(
        opacity: _isFadingOut ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 800),
        child: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const CircularProgressIndicator(color: Colors.blue),
        ),
      ),
    );
  }
}