import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/designer_service.dart';
import '../widgets/designer_app_background.dart';
import '../widgets/designer_glass_card.dart';

class DesignerAccountView extends StatefulWidget {
  const DesignerAccountView({super.key});
  @override
  State<DesignerAccountView> createState() => _DesignerAccountViewState();
}

class _DesignerAccountViewState extends State<DesignerAccountView> {
  late Future<Map<String, dynamic>> _user;
  @override
  void initState() { super.initState(); _reload(); }
  void _reload() => _user = AuthService.instance.currentUser();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('الملف الشخصي'), centerTitle: true),
    body: DesignerAppBackground(child: SafeArea(child: FutureBuilder<Map<String, dynamic>>(future: _user, builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError) return Center(child: OutlinedButton(onPressed: () => setState(_reload), child: const Text('إعادة المحاولة')));
      final user = snapshot.data!;
      return ListView(padding: const EdgeInsets.fromLTRB(24, 20, 24, 100), children: [
        DesignerGlassCard(padding: const EdgeInsets.all(22), borderRadius: 24, child: Column(children: [
          CircleAvatar(radius: 42, backgroundImage: user['avatarUrl'] == null ? null : NetworkImage(user['avatarUrl'].toString()), child: user['avatarUrl'] == null ? const Icon(Icons.person_outline, size: 42) : null),
          const SizedBox(height: 12), Text(user['displayName']?.toString() ?? '', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)), Text(user['email']?.toString() ?? ''), Text(user['city']?.toString() ?? ''), if (user['bio']?.toString().isNotEmpty == true) Padding(padding: const EdgeInsets.only(top: 10), child: Text(user['bio'].toString(), textAlign: TextAlign.center)),
        ])),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: () => _edit(user), icon: const Icon(Icons.edit_outlined), label: const Text('تعديل الملف الحقيقي')),
        const SizedBox(height: 10),
        OutlinedButton.icon(onPressed: () async { await AuthService.instance.clearSession(); if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst); }, icon: const Icon(Icons.logout), label: const Text('تسجيل الخروج')),
      ]);
    }))),
  );

  Future<void> _edit(Map<String, dynamic> user) async {
    final name = TextEditingController(text: user['displayName']?.toString()), city = TextEditingController(text: user['city']?.toString()), bio = TextEditingController(text: user['bio']?.toString());
    final saved = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('تعديل الملف'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: const InputDecoration(labelText: 'الاسم')), TextField(controller: city, decoration: const InputDecoration(labelText: 'المدينة')), TextField(controller: bio, maxLines: 3, decoration: const InputDecoration(labelText: 'النبذة'))]), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حفظ'))]));
    if (saved != true) return;
    try { await DesignerService.instance.updateAccount(displayName: name.text.trim(), city: city.text.trim(), bio: bio.text.trim()); if (mounted) setState(_reload); } on ApiException catch (error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message))); }
  }
}
