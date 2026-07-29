import 'package:flutter/material.dart';
// 1. This import links the main file to your newly created splash screen
import 'screens/splash_screen.dart'; 

void main() {
  runApp(const AmberDesignApp());
}

/// The root widget of the Amber Design application.
class AmberDesignApp extends StatelessWidget {
  const AmberDesignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amber Design',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // We will update this later when we set up app_colors.dart
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange), 
        useMaterial3: true,
      ),
      // 2. Here we tell the app to start with the SplashScreen
      home: const SplashScreen(), 
    );
  }
}