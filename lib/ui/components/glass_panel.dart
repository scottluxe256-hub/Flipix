import 'package:flutter/material.dart';
import 'dart:ui';

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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2), // Efek transparan halus
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}