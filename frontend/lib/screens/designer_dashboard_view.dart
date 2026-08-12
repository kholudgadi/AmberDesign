import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/designer_service.dart';
import '../utils/app_colors.dart';
import '../widgets/designer_app_background.dart';
import '../widgets/designer_glass_card.dart';

class DesignerDashboardView extends StatefulWidget {
  final Function(int) onTabChange;
  const DesignerDashboardView({super.key, required this.onTabChange});

  @override
  State<DesignerDashboardView> createState() => _DesignerDashboardViewState();
}

class _DesignerDashboardViewState extends State<DesignerDashboardView> {
  late Future<Map<String, dynamic>> _dashboard;
  @override
  void initState() { super.initState(); _reload(); }
  void _reload() => _dashboard = DesignerService.instance.dashboard();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('الرئيسية'), centerTitle: true),
    body: DesignerAppBackground(child: SafeArea(child: FutureBuilder<Map<String, dynamic>>(
      future: _dashboard,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) {
          final message = snapshot.error is ApiException ? (snapshot.error as ApiException).message : 'تعذر تحميل لوحة المصمم';
          return Center(child: OutlinedButton(onPressed: () => setState(_reload), child: Text('$message — إعادة المحاولة')));
        }
        final data = snapshot.data!;
        final profile = data['profile'] as Map<String, dynamic>;
        final assigned = data['assignedRequests'] as Map<String, dynamic>? ?? const {};
        final activeCount = assigned.entries.where((entry) => !['completed', 'cancelled'].contains(entry.key)).fold<int>(0, (sum, entry) => sum + (entry.value as num).toInt());
        final portfolio = (data['portfolio'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
        final reviews = (data['recentReviews'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
        return RefreshIndicator(onRefresh: () async => setState(_reload), child: ListView(padding: const EdgeInsets.fromLTRB(24, 18, 24, 100), children: [
          DesignerGlassCard(padding: const EdgeInsets.all(20), borderRadius: 24, child: Row(children: [
            CircleAvatar(radius: 34, backgroundImage: profile['avatarUrl'] == null ? null : NetworkImage(profile['avatarUrl'].toString()), child: profile['avatarUrl'] == null ? const Icon(Icons.person_outline, size: 34) : null),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(profile['displayName']?.toString() ?? 'مصمم', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text(profile['city']?.toString() ?? 'لم تحدد المدينة', style: const TextStyle(color: AppColors.textMuted)), if (profile['bio']?.toString().isNotEmpty == true) Text(profile['bio'].toString(), maxLines: 2, overflow: TextOverflow.ellipsis)])),
          ])),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _metric('طلبات متاحة', data['availableRequests'] ?? 0, Icons.assignment_outlined, () => widget.onTabChange(2))),
            const SizedBox(width: 12),
            Expanded(child: _metric('طلبات نشطة', activeCount, Icons.work_outline, () => widget.onTabChange(3))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _metric('التقييم', (data['ratingAverage'] as num?)?.toStringAsFixed(1) ?? '0.0', Icons.star_outline, null)),
            const SizedBox(width: 12),
            Expanded(child: _metric('التقييمات', data['ratingCount'] ?? 0, Icons.reviews_outlined, null)),
          ]),
          const SizedBox(height: 24),
          const Text('معرض الأعمال', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (portfolio.isEmpty) const Text('لم تضف أعمالًا إلى محفظتك حتى الآن', style: TextStyle(color: AppColors.textMuted)),
          if (portfolio.isNotEmpty) SizedBox(height: 110, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: portfolio.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, index) { final images = portfolio[index]['images'] as List<dynamic>? ?? const []; return ClipRRect(borderRadius: BorderRadius.circular(16), child: images.isEmpty ? Container(width: 120, color: Colors.black12, child: const Icon(Icons.image_outlined)) : Image.network(images.first.toString(), width: 120, fit: BoxFit.cover)); })),
          const SizedBox(height: 24),
          const Text('آخر التقييمات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (reviews.isEmpty) const Padding(padding: EdgeInsets.only(top: 10), child: Text('لا توجد تقييمات حقيقية حتى الآن', style: TextStyle(color: AppColors.textMuted))),
          ...reviews.map((review) { final customer = review['customer'] as Map<String, dynamic>?; return ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.star, color: Colors.amber), title: Text('${review['rating']} / 5'), subtitle: Text(review['comment']?.toString() ?? 'بدون تعليق'), trailing: Text(customer?['displayName']?.toString() ?? 'عميل')); }),
        ]));
      },
    ))),
  );

  Widget _metric(String label, Object value, IconData icon, VoidCallback? onTap) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24), child: DesignerGlassCard(padding: const EdgeInsets.all(18), borderRadius: 24, child: Column(children: [Icon(icon, color: AppColors.textDark), const SizedBox(height: 8), Text('$value', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)), Text(label, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted))])));
}
