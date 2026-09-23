import 'package:flutter/material.dart';
import 'dart:math';

class CardWidget extends StatelessWidget {
  final bool isFlipped;
  final String imagePath;
  final VoidCallback onTap;

  const CardWidget({
    super.key,
    required this.isFlipped,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: isFlipped ? 180 : 0),
        duration: const Duration(milliseconds: 300),
        builder: (context, double value, child) {
          bool isBackVisible = value < 90;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Efek perspektif 3D
              ..rotateY(value * pi / 180),
            child: isBackVisible
                ? _buildCardSide('assets/images/card_back.webp')
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi), // Balik gambar depan agar tidak terbalik (mirror)
                    child: _buildCardSide(imagePath, isFront: true),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCardSide(String path, {bool isFront = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Kartu warna putih solid murni
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          // Gambar transparan ditumpuk di atas kartu putih
          child: Image.asset(path, fit: BoxFit.contain),
        ),
      ),
    );
  }
}