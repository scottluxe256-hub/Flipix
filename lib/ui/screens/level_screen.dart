import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';
import '../../core/game_state.dart';
import 'gameplay_screen.dart';

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  @override
  Widget build(BuildContext context) {
    final highestUnlocked = GameState.instance.highestLevelUnlocked;

    return Scaffold(
      body: Stack(
        children: [
          // Background gambar (tetap bg_windows.webp sesuai permintaan)
          Positioned.fill(
            child: Image.asset('assets/images/bg_windows.webp', fit: BoxFit.cover),
          ),

          // Tombol Kembali
          Positioned(
            top: 24,
            left: 24,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 40, color: Colors.white),
              tooltip: 'Kembali',
              onPressed: () {
                AudioManager.instance.playSfx('click.m4a');
                Navigator.pop(context);
              },
            ),
          ),

          // Grid Level 1 - 10
          Center(
            child: Container(
              width: 800,
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'PILIH LEVEL',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(2, 2)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      final int level = index + 1;
                      final bool isUnlocked = level <= highestUnlocked;

                      return GestureDetector(
                        onTap: () {
                          if (isUnlocked) {
                            AudioManager.instance.playSfx('click.m4a');
                            // Hentikan BGM lobby sebelum masuk ingame
                            AudioManager.instance.stopBgm();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GameplayScreen(level: level),
                              ),
                            ).then((_) {
                              // Saat kembali ke layar level, putar kembali BGM lobby & refresh tampilan level
                              AudioManager.instance.playBgm('output.m4a');
                              setState(() {});
                            });
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            gradient: isUnlocked
                                ? const LinearGradient(
                                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : const LinearGradient(
                                    colors: [Color(0xFF64748B), Color(0xFF475569)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isUnlocked ? Colors.white : Colors.white38,
                              width: isUnlocked ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(2, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: isUnlocked
                                ? Text(
                                    '$level',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.lock, size: 40, color: Colors.white70),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}