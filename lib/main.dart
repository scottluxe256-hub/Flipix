import 'package:flutter/material.dart';
import 'core/audio_manager.dart';
import 'ui/screens/intro_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioManager.instance.init();
  runApp(const FlipCardApp());
}

class FlipCardApp extends StatelessWidget {
  const FlipCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flip Card Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Segoe UI', // Font bawaan Windows
      ),
      // Akan diarahkan ke IntroScreen terlebih dahulu
      home: const IntroScreen(),
    );
  }
}