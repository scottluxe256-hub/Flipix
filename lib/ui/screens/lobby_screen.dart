import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/audio_manager.dart';
import 'level_screen.dart';
import '../components/settings_popup.dart'; // Pastikan path ini sesuai dengan letak file kamu

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
                  // Ikon menu berwarna abu-abu solid
                  icon: const Icon(Icons.menu, color: Color(0xFF616161), size: 32),
                  onPressed: () {
                    AudioManager.instance.playSfx('click.m4a');
                  },
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
                        color: const Color(0xFF616161), // Warna abu-abu
                        size: 30,
                      ),
                      onPressed: () {
                        AudioManager.instance.playSfx('click.m4a');
                        setState(() {
                          AudioManager.instance.toggleBgm(!AudioManager.instance.isBgmOn);
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Color(0xFF616161), size: 32),
                      onPressed: () {
                        AudioManager.instance.playSfx('click.m4a');
                        showDialog(
  context: context,
  builder: (_) => SettingsPopup(), 
).then((_) {
                          // Trigger render ulang setelah popup ditutup (untuk update icon volume)
                          setState(() {}); 
                        });
                      },
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
                        // Metode exit yang aman untuk Flutter
                        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
                          exit(0);
                        } else {
                          SystemNavigator.pop();
                        }
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