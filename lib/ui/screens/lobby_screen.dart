import 'dart:io';
import 'package:flutter/material.dart';
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
    AudioManager.instance.playSfx('click.m4a');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Cara Bermain', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          '1. Hafalkan posisi kartu saat hitung mundur persiapan (3 detik).\n\n'
          '2. Cocokkan 2 kartu bergambar sama untuk membuka kartu.\n\n'
          '3. Selesaikan semua kartu sebelum waktu habis untuk memenangkan level!\n\n'
          '4. Jika waktu habis sebelum semua kartu terbuka, Anda kalah.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AudioManager.instance.playSfx('click.m4a');
              Navigator.pop(context);
            },
            child: const Text('Tutup', style: TextStyle(color: Colors.blueAccent)),
          )
        ],
      ),
    );
  }

  void _showSettings() {
    AudioManager.instance.playSfx('click.m4a');
    showDialog(context: context, builder: (context) => const SettingsPopup());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gambar (tetap bg_windows.webp sesuai instruksi)
          Positioned.fill(
            child: Image.asset('assets/images/bg_windows.webp', fit: BoxFit.cover),
          ),

          // Tombol Rules (Kiri Atas) - Ikon Garis Tiga warna Grey
          Positioned(
            top: 24,
            left: 24,
            child: IconButton(
              icon: const Icon(Icons.menu, size: 40, color: Colors.grey),
              tooltip: 'Cara Bermain',
              onPressed: _showRules,
            ),
          ),

          // Tombol Settings (Kanan Atas) - Ikon Gerigi warna Grey
          Positioned(
            top: 24,
            right: 24,
            child: IconButton(
              icon: const Icon(Icons.settings, size: 40, color: Colors.grey),
              tooltip: 'Pengaturan',
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
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 6,
                    ),
                    onPressed: () {
                      AudioManager.instance.playSfx('click.m4a');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LevelScreen()),
                      );
                    },
                    child: const Text('NEXT', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 6,
                    ),
                    onPressed: () {
                      AudioManager.instance.playSfx('click.m4a');
                      // Langsung menutup aplikasi Windows seketika
                      exit(0);
                    },
                    child: const Text('EXIT', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
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