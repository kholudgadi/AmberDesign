import 'role_selection_screen.dart';
import 'package:flutter/material.dart';

/// A screen that displays the initial splash UI.
/// Features a lightened background image, the company logo, and a navigation button.
/// Initial entry screen that introduces the app and directs users to role selection.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The primary action begins the account-role selection flow.
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image layer.
          Image.asset('assets/images/splash_bg.jpg', fit: BoxFit.cover),

          // Semi-transparent white overlay to lighten the background image.
          // Adjust opacity value (0.0 to 1.0) to control the lightening effect.
          Container(color: Colors.white.withOpacity(0.45)),

          // Foreground content containing the logo and navigation components.
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(),

                // Company logo.
                Image.asset('assets/images/Amber_Design_Logo.png', width: 250),

                const Spacer(),

                // Navigation button to proceed to the Login Screen.
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 40.0,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigates to the Role Selection Screen with a default sliding animation.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RoleSelectionScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      // Apply opacity to the background color for a translucent effect.
                      backgroundColor: const Color(
                        0xFF261732,
                      ).withOpacity(0.80),
                      // Remove elevation to prevent shadow rendering behind the translucent button.
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'التالي',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
