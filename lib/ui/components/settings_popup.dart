import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';
import '../../core/game_state.dart';

class SettingsPopup extends StatefulWidget {
  const SettingsPopup({super.key});

  @override
  State<SettingsPopup> createState() => _SettingsPopupState();
}

class _SettingsPopupState extends State<SettingsPopup> {
  late bool sfxEnabled;
  late bool bgmEnabled;

  @override
  void initState() {
    super.initState();
    sfxEnabled = AudioManager.instance.isSfxEnabled;
    bgmEnabled = AudioManager.instance.isBgmEnabled;
  }

  void _confirmResetProgress() {
    AudioManager.instance.playSfx('click.m4a');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Reset Progres?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Semua level akan dikunci kembali dan dimulai dari Level 1.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await GameState.instance.resetProgress();
              if (mounted) {
                Navigator.pop(ctx);
                Navigator.pop(context); // Tutup SettingsPopup
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Progres level berhasil direset ke Level 1!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Ya, Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Pengaturan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('BGM (Musik Latar)', style: TextStyle(color: Colors.white)),
            activeColor: Colors.blueAccent,
            value: bgmEnabled,
            onChanged: (value) {
              setState(() => bgmEnabled = value);
              AudioManager.instance.toggleBgm(value);
              AudioManager.instance.playSfx('click.m4a');
            },
          ),
          SwitchListTile(
            title: const Text('SFX (Efek Suara)', style: TextStyle(color: Colors.white)),
            activeColor: Colors.blueAccent,
            value: sfxEnabled,
            onChanged: (value) {
              setState(() => sfxEnabled = value);
              AudioManager.instance.toggleSfx(value);
              AudioManager.instance.playSfx('click.m4a');
            },
          ),
          const Divider(color: Colors.white24, height: 24),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: const Icon(Icons.restart_alt, color: Colors.orangeAccent),
            title: const Text('Reset Progres Level', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Mulai ulang dari Level 1', style: TextStyle(color: Colors.white54, fontSize: 12)),
            onTap: _confirmResetProgress,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            AudioManager.instance.playSfx('click.m4a');
            Navigator.pop(context);
          },
          child: const Text('Tutup', style: TextStyle(color: Colors.blueAccent)),
        ),
      ],
    );
  }
}