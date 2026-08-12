import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/orders_service.dart';
import '../utils/app_colors.dart';
import '../widgets/designer_app_background.dart';
import '../widgets/designer_glass_card.dart';
import 'track_order_screen.dart';

class DesignerManagementView extends StatefulWidget {
  final VoidCallback? onBack;
  const DesignerManagementView({super.key, this.onBack});

  @override
  State<DesignerManagementView> createState() => _DesignerManagementViewState();
}

class _DesignerManagementViewState extends State<DesignerManagementView> {
  String _status = 'all';
  late Future<List<Map<String, dynamic>>> _orders;

  static const _statuses = <String, String>{
    'all': 'الكل', 'assigned': 'مستلم', 'in_progress': 'قيد التنفيذ', 'ready': 'جاهز', 'completed': 'مكتمل'
  };

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _orders = OrdersService.instance.list();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: widget.onBack == null ? null : IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
      title: const Text('إدارة الطلبات'), centerTitle: true,
    ),
    body: DesignerAppBackground(
      child: SafeArea(child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _orders,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) {
            final message = snapshot.error is ApiException ? (snapshot.error as ApiException).message : 'تعذر تحميل الطلبات';
            return Center(child: OutlinedButton(onPressed: () => setState(_reload), child: Text('$message — إعادة المحاولة')));
          }
          final all = snapshot.data!.where((row) => row['kind'] == 'design_request').toList();
          final rows = _status == 'all' ? all : all.where((row) => row['status'] == _status).toList();
          return RefreshIndicator(
            onRefresh: () async => setState(_reload),
            child: ListView(padding: const EdgeInsets.fromLTRB(24, 18, 24, 100), children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<String>(
                  segments: _statuses.entries.map((entry) => ButtonSegment(value: entry.key, label: Text(entry.value))).toList(),
                  selected: {_status},
                  onSelectionChanged: (value) => setState(() => _status = value.first),
                ),
              ),
              const SizedBox(height: 20),
              if (rows.isEmpty) const Padding(padding: EdgeInsets.all(50), child: Center(child: Text('لا توجد طلبات في هذا القسم'))),
              ...rows.map((order) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackOrderScreen(orderId: order['id'].toString(), kind: 'design_request'))),
                  child: DesignerGlassCard(
                    padding: const EdgeInsets.all(18), borderRadius: 24,
                    child: Row(children: [
                      const CircleAvatar(radius: 27, child: Icon(Icons.assignment_outlined)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(order['title']?.toString() ?? 'طلب تصميم', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        const SizedBox(height: 7),
                        Text(_statuses[order['status']] ?? order['status']?.toString() ?? '', style: const TextStyle(color: AppColors.textMuted)),
                        const SizedBox(height: 5),
                        Text((order['customer'] as Map<String, dynamic>?)?['displayName']?.toString() ?? 'العميل'),
                      ])),
                      const Icon(Icons.arrow_back_ios_new, size: 16),
                    ]),
                  ),
                ),
              )),
            ]),
          );
        },
      )),
    ),
  );
}
