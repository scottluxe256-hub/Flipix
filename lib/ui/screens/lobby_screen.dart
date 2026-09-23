import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';
import 'level_screen.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  @override
  void initState() {
    super.initState();
    AudioManager.instance.playBgm('bgm_lobby.m4a');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_windows.webp'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 20,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.grey, size: 32),
                  onPressed: () {},
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        AudioManager.instance.isBgmOn
                            ? Icons.volume_up
                            : Icons.volume_off,
                        color: Colors.grey,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          AudioManager.instance.toggleBgm();
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.grey, size: 32),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        AudioManager.instance.playSfx('click.m4a');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LevelScreen()),
                        );
                      },
                      child: const Text(
                        'PLAY',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        AudioManager.instance.playSfx('click.m4a');
                        exit(0);
                      },
                      child: const Text(
                        'EXIT',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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