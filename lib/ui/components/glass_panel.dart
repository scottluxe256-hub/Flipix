import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;

  const GlassPanel({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85), // Frosted glass ringan tanpa beban Gaussian blur CPU
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}