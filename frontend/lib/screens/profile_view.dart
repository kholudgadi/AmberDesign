import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/app_background.dart';
import 'my_orders_view.dart';
import 'settings_screen.dart';
import 'edit_profile_screen.dart';
import 'support_screen.dart';
import '../screens/splash_screen.dart';

/// Account overview and navigation hub for profile-related actions.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  
  @override
  Widget build(BuildContext context) {
    // Routes users to account tools while keeping profile navigation in one place.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0).copyWith(bottom: 100),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 36,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'اسم المستخدم',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'user@example.com',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'مستخدم',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Profile actions available to the user.
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildMenuItem(
                  title: 'طلباتي',
                  onTap: () {
                    // Opens the orders list on a dedicated page so back navigation works.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: Scaffold(
                            extendBodyBehindAppBar: true,
                            appBar: AppBar(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              leading: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: AppColors.textDark,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              title: const Text(
                                'طلباتي',
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              centerTitle: true,
                            ),
                            body: const AppBackground(
                              child: SafeArea(
                                // Matches the home screen spacing while allowing the orders list to scroll.
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  physics: BouncingScrollPhysics(),
                                  child:
                                      MyOrdersView(), // Reuses the existing orders list widget.
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, color: Colors.black12),
                _buildMenuItem(
                  title: 'الإعدادات',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1, color: Colors.black12),
                _buildMenuItem(
                  title: 'تعديل الملف الشخصي',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1, color: Colors.black12),
                _buildMenuItem(
                  title: 'المساعدة والدعم',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SupportScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1, color: Colors.black12),
                _buildMenuItem(
                  title: 'تسجيل الخروج',
                  isLogout: true,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    // Applies consistent styling to regular and destructive profile actions.
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isLogout ? Colors.redAccent : AppColors.textDark,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_back_ios_new,
        size: 16,
        color: AppColors.textMuted,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    // Requires explicit confirmation before clearing the app's navigation history.
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFFF7F2EE),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('تسجيل الخروج', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
          content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج من حسابك؟', style: TextStyle(color: AppColors.textDark)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                // Close the confirmation dialog first.
                Navigator.pop(context); 
                
                // Clear navigation history and return to the entry screen.
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SplashScreen()), // Entry screen after logout.
                  (Route<dynamic> route) => false, // Removes every previous route.
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
