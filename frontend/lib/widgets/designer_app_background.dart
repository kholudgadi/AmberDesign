import 'package:flutter/material.dart';

/// Applies the shared background image with a heavier light overlay specifically for the designer flow.
class DesignerAppBackground extends StatelessWidget {
  final Widget child;

  const DesignerAppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Full-screen background image shared by the application's pages.
        Image.asset(
          'assets/images/splash_bg.jpg',
          fit: BoxFit.cover,
        ),
        
        Container(color: Colors.white.withOpacity(0.87)),
        
        child,
      ],
    );
  }
}