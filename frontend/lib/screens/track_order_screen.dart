import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/chat_service.dart';
import '../services/orders_service.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';
import 'chat_detail_screen.dart';

class TrackOrderScreen extends StatefulWidget {
  final String orderId;
  final String kind;
  const TrackOrderScreen({super.key, required this.orderId, this.kind = 'order'});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  late Future<Map<String, dynamic>> _order;
  bool _openingChat = false;
  bool _acceptingOffer = false;
  bool _rejectingOffer = false;
  bool _updatingStatus = false;
  String? _currentRole;

  static const _statuses = ['pending_payment', 'confirmed', 'accepted', 'in_progress', 'ready', 'shipped', 'completed'];
  static const _labels = ['بانتظار الدفع', 'تم تأكيد الطلب', 'قبل المصمم الطلب', 'قيد التنفيذ', 'جاهز', 'تم الشحن', 'مكتمل'];
  static const _designStatuses = ['submitted', 'assigned', 'quoted', 'accepted', 'in_progress', 'ready', 'completed'];
  static const _designLabels = ['تم إرسال الطلب', 'تم تعيين المصمم', 'وصل عرض السعر', 'تم قبول العرض', 'قيد التنفيذ', 'جاهز للمراجعة', 'مكتمل'];

  @override
  void initState() {
    super.initState();
    _order = OrdersService.instance.detail(widget.orderId, kind: widget.kind);
    _loadRole();
  }

  Future<void> _loadRole() async {
    final user = await AuthService.instance.currentUser();
    if (mounted) setState(() => _currentRole = user['role']?.toString());
  }

  Future<void> _updateDesignStatus(String status, String successMessage) async {
    if (_updatingStatus) return;
    setState(() => _updatingStatus = true);
    try {
      await OrdersService.instance.updateDesignRequestStatus(widget.orderId, status);
      if (!mounted) return;
      setState(() => _order = OrdersService.instance.detail(widget.orderId, kind: widget.kind));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage)));
    } on ApiException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _updatingStatus = false);
    }
  }

  Future<void> _acceptOffer() async {
    if (_acceptingOffer) return;
    setState(() => _acceptingOffer = true);
    try {
      await OrdersService.instance.acceptOffer(widget.orderId);
      if (!mounted) return;
      setState(() => _order = OrdersService.instance.detail(widget.orderId, kind: widget.kind));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم قبول العرض بنجاح')));
    } on ApiException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _acceptingOffer = false);
    }
  }

  Future<void> _rejectOffer() async {
    if (_rejectingOffer) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض العرض'),
        content: const Text('سيُعاد الطلب إلى قائمة الطلبات العامة ليتمكن مصمم آخر من إرسال عرض. هل تريد المتابعة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('تراجع')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('رفض العرض', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _rejectingOffer = true);
    try {
      await OrdersService.instance.rejectOffer(widget.orderId);
      if (!mounted) return;
      setState(() => _order = OrdersService.instance.detail(widget.orderId, kind: widget.kind));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفض العرض وإعادة الطلب للمصممين')));
    } on ApiException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _rejectingOffer = false);
    }
  }

  Future<void> _chat(Map<String, dynamic> order) async {
    final lines = order['lines'] as List<dynamic>? ?? const [];
    final assignedDesigner = order['assignedDesigner'] as Map<String, dynamic>?;
    final customer = order['customer'] as Map<String, dynamic>?;
    String? ownerId;
    if (widget.kind == 'design_request') {
      final currentUser = await AuthService.instance.currentUser();
      if (currentUser['role'] == 'designer') {
        ownerId = customer?['id']?.toString();
      } else {
        ownerId = assignedDesigner?['id']?.toString();
      }
    } else if (lines.isNotEmpty) {
      ownerId = (lines.first as Map<String, dynamic>)['ownerId']?.toString();
    }
    if (ownerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يوجد مصمم مرتبط بهذا الطلب')));
      return;
    }
    setState(() => _openingChat = true);
    try {
      String participantName = assignedDesigner?['displayName']?.toString() ?? 'المصمم';
      if (widget.kind == 'design_request' && customer?['id']?.toString() == ownerId) {
        participantName = customer?['displayName']?.toString() ?? 'العميل';
      }
      final conversationId = await ChatService.instance.openConversation(
        participantId: ownerId,
        orderId: widget.kind == 'order' ? widget.orderId : null,
        designRequestId: widget.kind == 'design_request' ? widget.orderId : null,
      );
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(
        conversationId: conversationId,
        participant: {
          'id': ownerId,
          'displayName': participantName,
        },
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
              final statuses = widget.kind == 'design_request' ? _designStatuses : _statuses;
              final labels = widget.kind == 'design_request' ? _designLabels : _labels;
              final current = statuses.indexOf(order['status']?.toString() ?? '');
              final history = order['history'] as List<dynamic>? ?? const [];
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  GlassCard(
                    padding: const EdgeInsets.all(22),
                    child: Column(children: List.generate(statuses.length, (index) {
                      final completed = index <= current;
                      Map<String, dynamic>? event;
                      for (final item in history.cast<Map<String, dynamic>>()) {
                        if (item['status'] == statuses[index]) {
                          event = item;
                          break;
                        }
                      }
                      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Column(children: [
                          Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, color: completed ? AppColors.textDark : Colors.transparent, border: Border.all(color: completed ? AppColors.textDark : AppColors.textMuted)), child: completed ? const Icon(Icons.check, size: 14, color: Colors.white) : null),
                          if (index < statuses.length - 1) Container(width: 2, height: 44, color: completed ? AppColors.textDark : Colors.black12),
                        ]),
                        const SizedBox(width: 14),
                        Expanded(child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(labels[index], style: TextStyle(fontWeight: completed ? FontWeight.bold : FontWeight.normal, color: completed ? AppColors.textDark : AppColors.textMuted)),
                            if (event != null) Text(event['note']?.toString() ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ]),
                        )),
                      ]);
                    })),
                  ),
                  const SizedBox(height: 20),
                  if (widget.kind == 'design_request' && order['quotedPrice'] != null) ...[
                    GlassCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('عرض المصمم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text('${order['quotedPrice']} ر.س', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        if (order['quoteDuration']?.toString().isNotEmpty ?? false) Text('مدة الإنجاز: ${order['quoteDuration']}'),
                        if (order['quoteDeliveryDate']?.toString().isNotEmpty ?? false) Text('تاريخ التسليم: ${order['quoteDeliveryDate']}'),
                        if (order['quoteMessage']?.toString().isNotEmpty ?? false) ...[
                          const SizedBox(height: 8),
                          Text(order['quoteMessage'].toString()),
                        ],
                      ]),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (widget.kind == 'design_request' && _currentRole == 'customer' && order['status'] == 'quoted') ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: (_acceptingOffer || _rejectingOffer) ? null : _rejectOffer,
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                            child: _rejectingOffer
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('رفض العرض'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: (_acceptingOffer || _rejectingOffer) ? null : _acceptOffer,
                            child: _acceptingOffer
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('قبول العرض'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (widget.kind == 'design_request' && _currentRole == 'designer' && order['status'] == 'accepted') ...[
                    _statusActionButton(
                      label: 'بدء التنفيذ',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () => _updateDesignStatus('in_progress', 'تم بدء تنفيذ الطلب'),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (widget.kind == 'design_request' && _currentRole == 'designer' && order['status'] == 'in_progress') ...[
                    _statusActionButton(
                      label: 'إرسال للمراجعة',
                      icon: Icons.task_alt,
                      onPressed: () => _updateDesignStatus('ready', 'تم إرسال الطلب للعميل للمراجعة'),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (widget.kind == 'design_request' && _currentRole == 'customer' && order['status'] == 'ready') ...[
                    _statusActionButton(
                      label: 'اعتماد وإكمال الطلب',
                      icon: Icons.verified_outlined,
                      onPressed: () => _updateDesignStatus('completed', 'تم اعتماد الطلب وإكماله'),
                    ),
                    const SizedBox(height: 20),
                  ],
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

  Widget _statusActionButton({required String label, required IconData icon, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _updatingStatus ? null : onPressed,
        icon: _updatingStatus
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Icon(icon),
        label: Text(label),
      ),
    );
  }
}
