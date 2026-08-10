import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../utils/app_colors.dart';
import '../widgets/app_background.dart';
import 'chat_detail_screen.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  late Future<({String userId, List<Map<String, dynamic>> rows})> _data;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _data = () async {
      final results = await Future.wait([
        AuthService.instance.currentUser(),
        ChatService.instance.conversations(),
      ]);
      return (userId: (results[0] as Map<String, dynamic>)['id'].toString(), rows: results[1] as List<Map<String, dynamic>>);
    }();
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('المحادثات')),
      body: AppBackground(
        child: SafeArea(
          child: FutureBuilder<({String userId, List<Map<String, dynamic>> rows})>(
            future: _data,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('تعذر تحميل المحادثات'),
                OutlinedButton(onPressed: () => setState(_reload), child: const Text('إعادة المحاولة')),
              ]));
              final data = snapshot.data!;
              if (data.rows.isEmpty) return const Center(child: Text('لا توجد محادثات حقيقية حتى الآن'));
              return RefreshIndicator(
                onRefresh: () async => setState(_reload),
                child: ListView.separated(
                  itemCount: data.rows.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final row = data.rows[index];
                    final participants = row['participants'] as List<dynamic>? ?? const [];
                    final other = participants
                        .map((p) => (p as Map<String, dynamic>)['user'] as Map<String, dynamic>)
                        .firstWhere((u) => u['id'].toString() != data.userId, orElse: () => <String, dynamic>{});
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                      title: Text(other['displayName']?.toString() ?? 'مستخدم Amber Design'),
                      subtitle: Text(row['lastMessage']?.toString() ?? 'ابدأ المحادثة', maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.arrow_back_ios_new, size: 14, color: AppColors.textMuted),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(
                        conversationId: row['id'].toString(),
                        participant: other,
                      ))),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}
