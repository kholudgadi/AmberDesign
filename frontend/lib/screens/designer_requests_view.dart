import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/orders_service.dart';
import '../utils/app_colors.dart';
import '../widgets/designer_app_background.dart';
import '../widgets/designer_glass_card.dart';
import 'designer_request_details_screen.dart';

class DesignerRequestsView extends StatefulWidget {
  final VoidCallback? onBack;
  const DesignerRequestsView({super.key, this.onBack});

  @override
  State<DesignerRequestsView> createState() => _DesignerRequestsViewState();
}

class _DesignerRequestsViewState extends State<DesignerRequestsView> {
  String _category = 'all';
  late Future<List<Map<String, dynamic>>> _requests;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _requests = OrdersService.instance.availableDesignRequests();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: widget.onBack == null ? null : IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
      title: const Text('تصفح الطلبات'),
      centerTitle: true,
    ),
    body: DesignerAppBackground(
      child: SafeArea(child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _requests,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) {
            final message = snapshot.error is ApiException ? (snapshot.error as ApiException).message : 'تعذر تحميل الطلبات';
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(message), const SizedBox(height: 12), OutlinedButton(onPressed: () => setState(_reload), child: const Text('إعادة المحاولة'))]));
          }
          final rows = snapshot.data!.where((row) => _category == 'all' || row['category'] == _category).toList();
          return RefreshIndicator(
            onRefresh: () async => setState(_reload),
            child: ListView(padding: const EdgeInsets.fromLTRB(24, 20, 24, 100), children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('الكل')),
                  ButtonSegment(value: 'fashion', label: Text('أزياء')),
                  ButtonSegment(value: 'interior', label: Text('داخلي')),
                ],
                selected: {_category},
                onSelectionChanged: (value) => setState(() => _category = value.first),
              ),
              const SizedBox(height: 20),
              if (rows.isEmpty) const Padding(padding: EdgeInsets.all(50), child: Center(child: Text('لا توجد طلبات متاحة حاليًا'))),
              ...rows.map((request) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () async {
                    final changed = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => DesignerRequestDetailsScreen(request: request)));
                    if (changed == true && mounted) setState(_reload);
                  },
                  child: DesignerGlassCard(
                    padding: const EdgeInsets.all(20), borderRadius: 24,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const CircleAvatar(child: Icon(Icons.design_services_outlined)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(request['title']?.toString() ?? 'طلب تصميم', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark))),
                        const Icon(Icons.arrow_back_ios_new, size: 16),
                      ]),
                      const SizedBox(height: 12),
                      Text(request['details']?.toString() ?? _specificationSummary(request), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textMuted)),
                      const SizedBox(height: 12),
                      Text('${request['category'] == 'interior' ? 'تصميم داخلي' : 'أزياء'} • ${_customerName(request)}', style: const TextStyle(fontWeight: FontWeight.w600)),
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

  String _customerName(Map<String, dynamic> request) => (request['customer'] as Map<String, dynamic>?)?['displayName']?.toString() ?? 'عميل';
  String _specificationSummary(Map<String, dynamic> request) {
    final specs = request['specifications'] as Map<String, dynamic>? ?? const {};
    return specs.values.map((value) => value.toString()).where((value) => value.isNotEmpty).join(' • ');
  }
}
