import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import 'role_selection_screen.dart' show RoleSelectionScreen;

class AccountScreen extends StatefulWidget {
  final Map<String, dynamic>? initialUser;
  const AccountScreen({super.key, this.initialUser});
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late Future<Map<String, dynamic>> _user;
  @override
  void initState() {
    super.initState();
    _user = widget.initialUser == null ? AuthService.instance.currentUser() : Future.value(widget.initialUser!);
  }
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
        automaticallyImplyLeading: Navigator.of(context).canPop(),
        leading: Navigator.of(context).canPop()
          ? IconButton(tooltip: 'العودة للرئيسية', onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back))
          : null,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _user,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text(snapshot.error.toString()));
          final user = snapshot.data!;
          return Center(child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.verified_user_outlined, size: 72, color: AppColors.textDark),
              const SizedBox(height: 16),
              Text(user['displayName']?.toString() ?? 'مستخدم أمبرديزاين', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(user['email']?.toString() ?? ''),
              const SizedBox(height: 8),
              Text(user['role'] == 'designer' ? 'حساب مصمم' : 'حساب عميل'),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: () async {
                await AuthService.instance.clearSession();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const RoleSelectionScreen()), (_) => false);
              }, child: const Text('تسجيل الخروج')),
            ]),
          ));
        },
      ),
    ),
  );
}
