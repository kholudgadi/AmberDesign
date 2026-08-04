import 'package:flutter/material.dart';
// This import links the main file to your newly created splash screen
import 'screens/splash_screen.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'utils/app_colors.dart';

void main() {
  runApp(const AmberDesignApp());
}

// The root widget of the Amber Design application.
class AmberDesignApp extends StatelessWidget {
  const AmberDesignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amber Design',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.cairoTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.textDark), 
        useMaterial3: true,
      ),
      // Here we tell the app to start with the SplashScreen
      home: const SplashScreen(), 
    );
  }
}