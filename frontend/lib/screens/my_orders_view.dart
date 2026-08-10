import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/orders_service.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_card.dart';
import 'track_order_screen.dart';

class MyOrdersView extends StatefulWidget {
  const MyOrdersView({super.key});

  @override
  State<MyOrdersView> createState() => _MyOrdersViewState();
}

class _MyOrdersViewState extends State<MyOrdersView> {
  late Future<List<Map<String, dynamic>>> _orders;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _orders = OrdersService.instance.list();

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Map<String, dynamic>>>(
    future: _orders,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Padding(padding: EdgeInsets.all(60), child: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.hasError) {
        final message = snapshot.error is ApiException
            ? (snapshot.error as ApiException).message
            : 'تعذر تحميل الطلبات';
        return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(message),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () => setState(_reload), child: const Text('إعادة المحاولة')),
        ]));
      }
      final orders = snapshot.data!;
      if (orders.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(60),
          child: Center(child: Text('لا توجد طلبات حقيقية في حسابك حتى الآن')),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: orders.length,
        itemBuilder: (_, index) => _orderCard(orders[index]),
      );
    },
  );

  Widget _orderCard(Map<String, dynamic> order) {
    final lines = order['lines'] as List<dynamic>? ?? const [];
    final first = lines.isEmpty ? null : lines.first as Map<String, dynamic>;
    final title = first?['titleAr']?.toString() ?? first?['titleEn']?.toString() ?? 'طلب #${order['id'].toString().substring(0, 8)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackOrderScreen(orderId: order['id'].toString()))),
        borderRadius: BorderRadius.circular(20),
        child: GlassCard(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            const CircleAvatar(radius: 28, child: Icon(Icons.design_services_outlined)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Text(_statusLabel(order['status']?.toString()), style: const TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 6),
              Text('${order['total'] ?? 0} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
            ])),
            const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.textMuted),
          ]),
        ),
      ),
    );
  }

  String _statusLabel(String? status) => const {
    'pending_payment': 'بانتظار الدفع',
    'confirmed': 'تم تأكيد الطلب',
    'accepted': 'قبل المصمم الطلب',
    'in_progress': 'قيد التنفيذ',
    'ready': 'جاهز',
    'shipped': 'تم الشحن',
    'completed': 'مكتمل',
    'cancelled': 'ملغي',
    'refunded': 'مسترجع',
  }[status] ?? status ?? '';
}
