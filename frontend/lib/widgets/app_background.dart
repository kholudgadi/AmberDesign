import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. صورة الخلفية
        Image.asset(
          'assets/images/splash_bg.jpg',
          fit: BoxFit.cover,
        ),
        
        Container(color: Colors.white.withOpacity(0.45)),
        
        child,
      ],
    );
  }
}