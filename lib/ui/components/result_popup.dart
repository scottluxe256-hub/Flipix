import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResultPopup extends StatelessWidget {
  final bool isWin;
  final int score;
  final VoidCallback onNextOrRetry;
  final VoidCallback onExit;

  const ResultPopup({
    super.key,
    required this.isWin,
    required this.score,
    required this.onNextOrRetry,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        isWin ? 'Level Completed!' : 'Game Over',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isWin ? Colors.green : Colors.red,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Total Score', style: TextStyle(fontSize: 18, color: Colors.black54)),
          Text('$score', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Tombol warna biru sesuai permintaan
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: onNextOrRetry,
              child: Text(isWin ? 'Next Stage' : 'Try Again', style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: onExit,
              child: const Text('Exit', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}