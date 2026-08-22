import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// This import links the main file to your newly created splash screen
import 'screens/splash_screen.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'utils/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Starts the Flutter widget tree with the application's root configuration.
  runApp(const AmberDesignApp());
}

// The root widget of the Amber Design application.
class AmberDesignApp extends StatelessWidget {
  const AmberDesignApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Defines the app-wide theme and the first screen shown to the user.
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
