import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Pengaturan', style: TextStyle(color: Colors.white)),
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