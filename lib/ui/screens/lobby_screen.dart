import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/audio_manager.dart';
import '../components/settings_popup.dart';
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
    // Putar BGM Lobby
    AudioManager.instance.playBgm('output.m4a');
  }

  void _showRules() {
    AudioManager.instance.playSfx('click.opus');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cara Bermain'),
        content: const Text('Hafalkan posisi kartu saat hitung mundur.\n\nCocokkan 2 gambar yang sama untuk mendapatkan poin. Selesaikan sebelum waktu habis!'),
        actions: [
          TextButton(
            onPressed: () {
              AudioManager.instance.playSfx('click.opus');
              Navigator.pop(context);
            },
            child: const Text('Tutup'),
          )
        ],
      ),
    );
  }

  void _showSettings() {
    AudioManager.instance.playSfx('click.opus');
    showDialog(context: context, builder: (context) => const SettingsPopup());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gambar
          Positioned.fill(
            child: Image.asset('assets/images/bg_windows.webp', fit: BoxFit.cover),
          ),
          
          // Tombol Rules (Kiri Atas)
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.menu, size: 40, color: Colors.white),
              onPressed: _showRules,
            ),
          ),
          
          // Tombol Settings (Kanan Atas)
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.settings, size: 40, color: Colors.white),
              onPressed: _showSettings,
            ),
          ),

          // Tombol Next & Exit di tengah bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {
                      AudioManager.instance.playSfx('click.opus');
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LevelScreen()));
                    },
                    child: const Text('NEXT', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {
                      AudioManager.instance.playSfx('click.opus');
                      SystemNavigator.pop(); // Keluar aplikasi Windows
                    },
                    child: const Text('EXIT', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
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