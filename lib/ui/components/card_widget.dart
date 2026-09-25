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
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: isFlipped ? 180 : 0),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic,
          builder: (context, double value, _) {
            final bool isBackVisible = value < 90;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012) // Efek perspektif 3D yang realistis
                ..rotateY(value * pi / 180),
              child: isBackVisible
                  ? _buildCardSide('assets/images/card_back.webp')
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi),
                      child: _buildCardSide(imagePath, isFront: true),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardSide(String path, {bool isFront = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        // Box shadow tipis, elegan dan modern
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 6,
            spreadRadius: 0.5,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Image.asset(path, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
