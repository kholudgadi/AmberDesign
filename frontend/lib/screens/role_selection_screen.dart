import 'package:flutter/material.dart';
import 'user_onboarding_screen.dart';
import 'login_screen.dart';

// ---- Color palette ----
class AppColors {
  static const cream = Color(0xFFEDE7DD);
  static const textDark = Color.fromARGB(255, 38, 23, 50);
  static const textMuted = Color.fromARGB(255, 90, 74, 94);
}

/// Screen allowing the user to select their account type (User or Designer).
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset('assets/images/splash_bg.jpg', fit: BoxFit.cover),

            // Soft overlay
            Container(color: Colors.white.withOpacity(0.45)),

            SafeArea(
              child: Column(
                children: [
                  const _TopBar(),
                  const Spacer(flex: 2),

                  // Logo
                  Image.asset(
                    'assets/images/Amber_Design_Logo.png',
                    width: 244,
                    height: 244,
                  ),

                  const Spacer(flex: 1),
                  const _Heading(),
                  const SizedBox(height: 28),

                  // Role Cards
                  _RoleCards(),

                  const Spacer(flex: 2),
                  const _Footer(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Top bar: back arrow + interactive language toggle ----
class _TopBar extends StatefulWidget {
  const _TopBar();

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> {
  bool isArabic = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),

            // Language toggle button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(
                  217,
                  217,
                  217,
                  0.50,
                ).withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color.fromRGBO(38, 23, 50, 0.10),
                  width: 0.8,
                ),
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => isArabic = true),
                      child: Text(
                        'ع',
                        style: TextStyle(
                          color: isArabic
                              ? AppColors.textDark
                              : AppColors.textMuted.withOpacity(0.6),
                          fontWeight: isArabic
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      ' | ',
                      style: TextStyle(
                        color: AppColors.textMuted.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => isArabic = false),
                      child: Text(
                        'EN',
                        style: TextStyle(
                          color: !isArabic
                              ? AppColors.textDark
                              : AppColors.textMuted.withOpacity(0.6),
                          fontWeight: !isArabic
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Heading ----
class _Heading extends StatelessWidget {
  const _Heading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'من أنت؟',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            fontFamily: 'NotoSansArabic',
          ),
        ),
        SizedBox(height: 2),
        Text(
          'اختر نوع حسابك للمتابعة',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textMuted,
            fontFamily: 'NotoSansArabic',
          ),
        ),
      ],
    );
  }
}

// ---- Role selection cards ----
class _RoleCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // button 1 (User)
          _RoleCard(
            icon: Icons.person_outline,
            title: 'دخول كمستخدم',
            subtitle: 'تصفحي وطلب فساتين مميزة',
            backgroundColor: Colors.white.withOpacity(0.28),
            borderColor: Colors.white.withOpacity(0.1),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserOnboardingScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // button 2 (Designer)
          _RoleCard(
            icon: Icons.work_outline,
            title: 'دخول كمصمم',
            subtitle: 'اعرض أعمالك واحصل على طلبات',
            backgroundColor: AppColors.textDark.withOpacity(0.03),
            borderColor: const Color.fromRGBO(38, 23, 50, 1).withOpacity(0.1),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(isDesigner: true),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---- Reusable Role Card Component ----
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Row(
            children: [
              // 1. Icon circle
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromRGBO(38, 24, 50, 0.05),
                  border: Border.all(
                    color: AppColors.textDark.withOpacity(0.1),
                    width: 1.2,
                  ),
                ),
                child: Icon(icon, color: AppColors.textDark, size: 24),
              ),

              const SizedBox(width: 16),

              // 2. Texts (Middle)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Chevron
              Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textMuted.withOpacity(0.6),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- Footer ----
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Amber design © 2025',
      style: TextStyle(
        color: const Color(0xFF5a4a5e).withOpacity(0.5),
        fontSize: 13,
      ),
    );
  }
}
