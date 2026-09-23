import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';
import '../../core/game_state.dart';
import 'gameplay_screen.dart';

class LevelScreen extends StatelessWidget {
  const LevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = GameState.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA),
      appBar: AppBar(
        title: const Text('Select Level'),
        backgroundColor: Colors.lightBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: 10,
          itemBuilder: (context, index) {
            final level = index + 1;
            final isUnlocked = level <= gameState.highestUnlockedLevel;

            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isUnlocked ? Colors.lightBlueAccent : Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: isUnlocked
                  ? () {
                      AudioManager.instance.playSfx('click.m4a');
                      gameState.setLevel(level);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameplayScreen(level: level),
                        ),
                      );
                    }
                  : null,
              child: Text(
                '$level',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}