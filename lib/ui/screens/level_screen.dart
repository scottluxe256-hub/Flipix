import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';
import 'gameplay_screen.dart';

// Variabel global sederhana untuk level (karena tidak pakai state management kompleks)
int highestLevelUnlockedGlobal = 1;

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg_windows.webp', fit: BoxFit.cover),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 40, color: Colors.white),
              onPressed: () {
                AudioManager.instance.playSfx('click.opus');
                Navigator.pop(context);
              },
            ),
          ),
          Center(
            child: Container(
              width: 800,
              padding: const EdgeInsets.only(top: 80),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: 10,
                itemBuilder: (context, index) {
                  int level = index + 1;
                  bool isUnlocked = level <= highestLevelUnlockedGlobal;

                  return GestureDetector(
                    onTap: () {
                      if (isUnlocked) {
                        AudioManager.instance.playSfx('click.opus');
                        // Stop BGM lobby sebelum masuk ingame
                        AudioManager.instance.stopBgm(); 
                        Navigator.push(context, MaterialPageRoute(builder: (_) => GameplayScreen(level: level)))
                            .then((_) {
                              // Saat kembali ke layar level, putar BGM lobby lagi dan refresh UI
                              AudioManager.instance.playBgm('output.m4a');
                              setState(() {});
                            });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isUnlocked ? Colors.blueAccent : Colors.grey,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 2))],
                      ),
                      child: Center(
                        child: isUnlocked
                            ? Text('$level', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white))
                            : const Icon(Icons.lock, size: 40, color: Colors.white70),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}