import 'package:flutter/material.dart';

/// Applies the shared background image and a light overlay behind a page.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Layers page content above the background so individual screens need no duplicate styling.
    return Stack(
      fit: StackFit.expand,
      children: [
        // Full-screen background image shared by the application's pages.
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
