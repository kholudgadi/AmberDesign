import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../screens/chats_list_screen.dart';
import '../screens/notifications_dialog.dart';
import '../screens/settings_screen.dart';
import '../screens/login_screen.dart';

/// Side navigation that delegates main tabs to the parent HomeScreen.
class AppDrawer extends StatelessWidget {
  /// Receives the index of the main tab selected from the drawer.
  final ValueChanged<int> onTabSelected;

  const AppDrawer({super.key, required this.onTabSelected});

  void _selectTab(BuildContext context, int index) {
    // Close the drawer first, then render the selected tab in the existing home layout.
    Navigator.pop(context);
    onTabSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF0EBE6),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Image.asset('assets/images/Amber_Design_Logo.png', height: 100),
            const SizedBox(height: 16),
            const Text(
              'Amber design',
              style: TextStyle(fontSize: 18, color: AppColors.textDark),
            ),
            const SizedBox(height: 32),
            const Divider(height: 1, color: Colors.black12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _buildDrawerItem(
                    context,
                    'الرئيسية',
                    Icons.home_outlined,
                    () => _selectTab(context, 0),
                  ),
                  _buildDrawerItem(
                    context,
                    'طلب تصميم',
                    Icons.assignment_outlined,
                    () => _selectTab(context, 2),
                  ),
                  _buildDrawerItem(
                    context,
                    'طلباتي',
                    Icons.card_giftcard,
                    () => _selectTab(context, 3),
                  ),
                  _buildDrawerItem(context, 'المحادثات', Icons.chat_bubble_outline, () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatsListScreen()),
                    );
                  }),
                  _buildDrawerItem(context, 'الإشعارات', Icons.notifications_none, () {
                    Navigator.pop(context);
                    // Uses the same notification dialog opened by the bell icon in HomeScreen.
                    showNotificationsDialog(context);
                  }),
                  _buildDrawerItem(
                    context,
                    'ملفي الشخصي',
                    Icons.person_outline,
                    () => _selectTab(context, 4),
                  ),
                  _buildDrawerItem(context, 'الإعدادات', Icons.settings_outlined, () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  }),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.black12),
            ListTile(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'تسجيل الخروج',
                style: TextStyle(fontSize: 16, color: Colors.redAccent),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.textDark),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.textDark,
          fontWeight: FontWeight.w500,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
