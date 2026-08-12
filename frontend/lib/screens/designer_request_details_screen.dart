import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/orders_service.dart';
import '../utils/app_colors.dart';
import '../widgets/designer_app_background.dart';
import '../widgets/designer_glass_card.dart';
import 'track_order_screen.dart';

class DesignerRequestDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> request;
  const DesignerRequestDetailsScreen({super.key, required this.request});

  @override
  State<DesignerRequestDetailsScreen> createState() => _DesignerRequestDetailsScreenState();
}

class _DesignerRequestDetailsScreenState extends State<DesignerRequestDetailsScreen> {
  bool _claiming = false;

  Future<void> _claim() async {
    setState(() => _claiming = true);
    try {
      final claimed = await OrdersService.instance.claimDesignRequest(widget.request['id'].toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم استلام الطلب وفتح المحادثة مع العميل')));
      await Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TrackOrderScreen(orderId: claimed['id'].toString(), kind: 'design_request')));
    } on ApiException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _claiming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final customer = request['customer'] as Map<String, dynamic>?;
    final specs = request['specifications'] as Map<String, dynamic>? ?? const {};
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الطلب')),
        body: DesignerAppBackground(
          child: SafeArea(child: ListView(padding: const EdgeInsets.all(24), children: [
            DesignerGlassCard(
              padding: const EdgeInsets.all(24), borderRadius: 24,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ListTile(contentPadding: EdgeInsets.zero, leading: const CircleAvatar(child: Icon(Icons.person_outline)), title: Text(customer?['displayName']?.toString() ?? 'عميل'), subtitle: Text(customer?['city']?.toString() ?? '')),
                const Divider(),
                Text(request['title']?.toString() ?? 'طلب تصميم', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                if (request['details']?.toString().isNotEmpty == true) ...[const SizedBox(height: 12), Text(request['details'].toString())],
                const SizedBox(height: 20),
                _row('الفئة', request['category'] == 'interior' ? 'تصميم داخلي' : 'أزياء'),
                ...specs.entries.map((entry) => _row(entry.key, entry.value.toString())),
                _row('رسوم الخدمة', '${request['serviceFee'] ?? 0} ر.س'),
                _row('رسوم المنصة', '${request['platformFee'] ?? 0} ر.س'),
              ]),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(onPressed: _claiming ? null : _claim, icon: const Icon(Icons.check_circle_outline), label: Text(_claiming ? 'جارٍ الاستلام...' : 'استلام الطلب وبدء المحادثة')),
            const SizedBox(height: 10),
            OutlinedButton(onPressed: () => Navigator.pop(context, false), child: const Text('رجوع')),
          ])),
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 9), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Text(label, style: const TextStyle(color: AppColors.textMuted))), Expanded(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold)))]));
}
