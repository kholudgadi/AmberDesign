import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/global_data.dart';
import '../screens/designer_edit_portfolio_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/designer_chats_view.dart';
import '../screens/designer_support_screen.dart';

class DesignerDrawer extends StatelessWidget {
  final Function(int) onTabChange;

  const DesignerDrawer({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final profile = GlobalData.designerProfile;

    return Drawer(
      backgroundColor: const Color(0xFFFBF9F6),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
              bottom: 24,
              right: 24,
              left: 24,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF2E1B3D),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  profile['name'] ?? 'نوف الأحمدي',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile['role'] ?? 'مصممة أزياء',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildDrawerItem(Icons.home_outlined, 'الرئيسية', () {
                  Navigator.pop(context);
                  onTabChange(0);
                }),

                _buildDrawerItem(Icons.chat_bubble_outline, 'المحادثات', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DesignerChatsView(),
                    ),
                  );
                }),

                _buildDrawerItem(Icons.inventory_2_outlined, 'منتجاتي', () {
                  Navigator.pop(context);
                  onTabChange(1);
                }),
                _buildDrawerItem(
                  Icons.assignment_outlined,
                  'إدارة الطلبات',
                  () {
                    Navigator.pop(context);
                    onTabChange(3);
                  },
                ),
                _buildDrawerItem(
                  Icons.photo_library_outlined,
                  'تعديل المحفظة',
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DesignerEditPortfolioScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(Icons.person_outline, 'الملف الشخصي', () {
                  Navigator.pop(context);
                  onTabChange(4);
                }),
                _buildDrawerItem(Icons.headset_mic_outlined, 'الدعم الفني', () {
                  Navigator.pop(context); 
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DesignerSupportScreen(),
                    ),
                  );
                }),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildDrawerItem(
              Icons.logout,
              'تسجيل الخروج',
              () => _showLogoutBottomSheet(context),
              isLogout: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? const Color(0xFFD32F2F) : AppColors.textDark,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isLogout ? const Color(0xFFD32F2F) : AppColors.textDark,
        ),
      ),
      onTap: onTap,
      horizontalTitleGap: 16,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  void _showLogoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.only(
              top: 32,
              left: 24,
              right: 24,
              bottom: 40,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'تسجيل الخروج؟',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟',
                  style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SplashScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF44336),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'تسجيل الخروج',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            235,
                            235,
                            235,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
