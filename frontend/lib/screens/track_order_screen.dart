import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/chat_service.dart';
import '../services/orders_service.dart';
import '../utils/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';
import 'chat_detail_screen.dart';

class TrackOrderScreen extends StatefulWidget {
  final String orderId;
  const TrackOrderScreen({super.key, required this.orderId});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  late Future<Map<String, dynamic>> _order;
  bool _openingChat = false;

  static const _statuses = ['pending_payment', 'confirmed', 'accepted', 'in_progress', 'ready', 'shipped', 'completed'];
  static const _labels = ['بانتظار الدفع', 'تم تأكيد الطلب', 'قبل المصمم الطلب', 'قيد التنفيذ', 'جاهز', 'تم الشحن', 'مكتمل'];

  @override
  void initState() {
    super.initState();
    _order = OrdersService.instance.detail(widget.orderId);
  }

  Future<void> _chat(Map<String, dynamic> order) async {
    final lines = order['lines'] as List<dynamic>? ?? const [];
    final ownerId = lines.isEmpty ? null : (lines.first as Map<String, dynamic>)['ownerId']?.toString();
    if (ownerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يوجد مصمم مرتبط بهذا الطلب')));
      return;
    }
    setState(() => _openingChat = true);
    try {
      final conversationId = await ChatService.instance.openConversation(participantId: ownerId, orderId: widget.orderId);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(
        conversationId: conversationId,
        participant: {'id': ownerId, 'displayName': 'المصمم'},
      )));
    } on ApiException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _openingChat = false);
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('تتبع الطلب')),
      body: AppBackground(
        child: SafeArea(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _order,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return const Center(child: Text('تعذر تحميل تفاصيل الطلب'));
              final order = snapshot.data!;
              final current = _statuses.indexOf(order['status']?.toString() ?? '');
              final history = order['history'] as List<dynamic>? ?? const [];
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  GlassCard(
                    padding: const EdgeInsets.all(22),
                    child: Column(children: List.generate(_statuses.length, (index) {
                      final completed = index <= current;
                      Map<String, dynamic>? event;
                      for (final item in history.cast<Map<String, dynamic>>()) {
                        if (item['status'] == _statuses[index]) {
                          event = item;
                          break;
                        }
                      }
                      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Column(children: [
                          Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, color: completed ? AppColors.textDark : Colors.transparent, border: Border.all(color: completed ? AppColors.textDark : AppColors.textMuted)), child: completed ? const Icon(Icons.check, size: 14, color: Colors.white) : null),
                          if (index < _statuses.length - 1) Container(width: 2, height: 44, color: completed ? AppColors.textDark : Colors.black12),
                        ]),
                        const SizedBox(width: 14),
                        Expanded(child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(_labels[index], style: TextStyle(fontWeight: completed ? FontWeight.bold : FontWeight.normal, color: completed ? AppColors.textDark : AppColors.textMuted)),
                            if (event != null) Text(event['note']?.toString() ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ]),
                        )),
                      ]);
                    })),
                  ),
                  const SizedBox(height: 20),
                  GlassCard(
                    padding: const EdgeInsets.all(18),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                      title: const Text('التواصل مع المصمم'),
                      subtitle: const Text('المحادثة مرتبطة بهذا الطلب وتحفظ في حسابك'),
                      trailing: _openingChat ? const CircularProgressIndicator() : const Icon(Icons.chat_bubble_outline),
                      onTap: _openingChat ? null : () => _chat(order),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}
