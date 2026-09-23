import 'package:flutter/material.dart';
import 'core/audio_manager.dart';
import 'ui/screens/intro_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioManager.instance.init();
  runApp(const FlipCardGame());
}

class FlipCardGame extends StatelessWidget {
  const FlipCardGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flip Card Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const IntroScreen(),
    );
  }
}