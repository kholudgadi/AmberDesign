import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/orders_service.dart';
import '../utils/app_colors.dart';
import '../widgets/designer_app_background.dart';
import '../widgets/designer_glass_card.dart';
import 'track_order_screen.dart';

class DesignerRequestsScreen extends StatefulWidget {
  const DesignerRequestsScreen({super.key});

  @override
  State<DesignerRequestsScreen> createState() => _DesignerRequestsScreenState();
}

class _DesignerRequestsScreenState extends State<DesignerRequestsScreen> {
  late Future<List<List<Map<String, dynamic>>>> _requests;
  String? _claimingId;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _requests = Future.wait([
    OrdersService.instance.availableDesignRequests(),
    OrdersService.instance.list(),
  ]);

  Future<void> _claim(String id) async {
    setState(() => _claimingId = id);
    try {
      await OrdersService.instance.claimDesignRequest(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم استلام الطلب وفتح المحادثة مع العميل')));
      setState(_reload);
    } on ApiException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _claimingId = null);
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('طلبات التصميم')),
      body: DesignerAppBackground(
        child: SafeArea(child: FutureBuilder<List<List<Map<String, dynamic>>>>(
          future: _requests,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return Center(child: OutlinedButton(onPressed: () => setState(_reload), child: const Text('تعذر التحميل — إعادة المحاولة')));
            final available = snapshot.data![0];
            final mine = snapshot.data![1].where((row) => row['kind'] == 'design_request').toList();
            return RefreshIndicator(
              onRefresh: () async => setState(_reload),
              child: ListView(padding: const EdgeInsets.all(20), children: [
                const Text('طلبات متاحة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 12),
                if (available.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text('لا توجد طلبات متاحة حاليًا')),
                ...available.map((request) => _card(request, available: true)),
                const SizedBox(height: 24),
                const Text('طلباتي المستلمة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 12),
                if (mine.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text('لم تستلم أي طلب بعد')),
                ...mine.map((request) => _card(request, available: false)),
              ]),
            );
          },
        )),
      ),
    ),
  );

  Widget _card(Map<String, dynamic> request, {required bool available}) {
    final id = request['id'].toString();
    final customer = request['customer'] as Map<String, dynamic>?;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DesignerGlassCard(
        padding: const EdgeInsets.all(18),
        borderRadius: 20,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(request['title']?.toString() ?? 'طلب تصميم', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('${request['category'] == 'interior' ? 'تصميم داخلي' : 'أزياء'}${customer == null ? '' : ' • ${customer['displayName']}'}'),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: available
            ? FilledButton(onPressed: _claimingId == id ? null : () => _claim(id), child: Text(_claimingId == id ? 'جارٍ الاستلام...' : 'استلام الطلب'))
            : OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackOrderScreen(orderId: id, kind: 'design_request'))), child: const Text('التفاصيل والمحادثة'))),
        ]),
      ),
    );
  }
}
