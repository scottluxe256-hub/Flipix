import 'package:flutter/material.dart';
import 'dart:math';

class CardWidget extends StatelessWidget {
  final bool isFlipped;
  final bool isMatched;
  final String imagePath;
  final VoidCallback onTap;

  const CardWidget({
    super.key,
    required this.isFlipped,
    required this.isMatched,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: isFlipped || isMatched ? 180 : 0),
        duration: const Duration(milliseconds: 250), // Dipercepat sedikit agar terasa lebih 60fps
        builder: (context, double value, child) {
          bool isBackVisible = value < 90;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(value * pi / 180),
            child: isBackVisible
                ? _buildCardSide('assets/images/card_back.webp')
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    // Beri efek redup jika kartu sudah berpasangan (matched)
                    child: Opacity(
                      opacity: isMatched ? 0.6 : 1.0,
                      child: _buildCardSide(imagePath, isFront: true),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCardSide(String path, {bool isFront = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(path, fit: BoxFit.contain),
        ),
      ),
    );
  }
}