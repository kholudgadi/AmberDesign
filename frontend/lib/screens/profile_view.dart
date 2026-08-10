import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_card.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'my_orders_view.dart';
import 'settings_screen.dart';
import 'support_screen.dart';

/// Account overview backed by the currently authenticated backend user.
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late Future<Map<String, dynamic>> _user;

  @override
  void initState() {
    super.initState();
    _user = AuthService.instance.currentUser();
  }

  void _reload() => setState(() => _user = AuthService.instance.currentUser());

  Future<void> _openEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _user,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(60),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          final message = snapshot.error is ApiException
              ? (snapshot.error as ApiException).message
              : 'تعذر تحميل بيانات الحساب';
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                const SizedBox(height: 12),
                OutlinedButton(onPressed: _reload, child: const Text('إعادة المحاولة')),
              ],
            ),
          );
        }

        final user = snapshot.data!;
        final name = user['displayName']?.toString().trim();
        final email = user['email']?.toString().trim();
        final role = user['role'] == 'designer' ? 'مصمم' : 'مستخدم';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12).copyWith(bottom: 100),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              InkWell(
                onTap: _openEditProfile,
                borderRadius: BorderRadius.circular(24),
                child: GlassCard(
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
                        child: const Icon(Icons.person_outline, size: 36, color: AppColors.textDark),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name?.isNotEmpty == true ? name! : 'مستخدم Amber Design',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email?.isNotEmpty == true ? email! : 'لا يوجد بريد إلكتروني',
                              style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 8),
                            Text(role, style: const TextStyle(fontSize: 11, color: AppColors.textDark)),
                          ],
                        ),
                      ),
                      const Icon(Icons.edit_outlined, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _menu('طلباتي', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _OrdersPage()))),
                    const Divider(height: 1, color: Colors.black12),
                    _menu('الإعدادات', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
                    const Divider(height: 1, color: Colors.black12),
                    _menu('تعديل الملف الشخصي', _openEditProfile),
                    const Divider(height: 1, color: Colors.black12),
                    _menu('المساعدة والدعم', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()))),
                    const Divider(height: 1, color: Colors.black12),
                    _menu('تسجيل الخروج', () => _confirmLogout(context), isLogout: true),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _menu(String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      onTap: onTap,
      title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isLogout ? Colors.redAccent : AppColors.textDark)),
      trailing: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء')),
            ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('تأكيد')),
          ],
        ),
      ),
    );
    if (confirmed != true || !mounted) return;
    await AuthService.instance.clearSession();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }
}

class _OrdersPage extends StatelessWidget {
  const _OrdersPage();

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('طلباتي')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: MyOrdersView(),
      ),
    ),
  );
}
