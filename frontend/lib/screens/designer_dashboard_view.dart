import 'dart:ui';

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
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _dashboard = DesignerService.instance.dashboard();

  Future<void> _refresh() async {
    setState(_reload);
    await _dashboard;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'الملف الشخصي',
          icon: const Icon(Icons.menu, color: AppColors.textDark, size: 28),
          onPressed: () => widget.onTabChange(4),
        ),
        title: const Text(
          'الرئيسية',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'الإشعارات',
            icon: const Icon(
              Icons.notifications_none,
              color: AppColors.textDark,
            ),
            onPressed: _showNotifications,
          ),
        ],
      ),
      body: DesignerAppBackground(
        child: SafeArea(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _dashboard,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                final error = snapshot.error;
                final message = error is ApiException
                    ? error.message
                    : 'تعذر تحميل لوحة المصمم';
                return Center(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(_reload),
                    icon: const Icon(Icons.refresh),
                    label: Text('$message — إعادة المحاولة'),
                  ),
                );
              }
              return _dashboardBody(snapshot.data!);
            },
          ),
        ),
      ),
    );
  }

  Widget _dashboardBody(Map<String, dynamic> data) {
    final profile = data['profile'] as Map<String, dynamic>? ?? const {};
    final assigned =
        data['assignedRequests'] as Map<String, dynamic>? ?? const {};
    final portfolio = (data['portfolio'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final reviews = (data['recentReviews'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final notifications =
        (data['recentNotifications'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>();
    final activeCount = assigned.entries
        .where((entry) => !const ['completed', 'cancelled'].contains(entry.key))
        .fold<int>(0, (sum, entry) => sum + (entry.value as num).toInt());
    final rating = (data['ratingAverage'] as num?)?.toDouble() ?? 0;
    final ratingCount = (data['ratingCount'] as num?)?.toInt() ?? 0;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 110),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  value: activeCount,
                  label: 'طلبات نشطة',
                  icon: Icons.inventory_2_outlined,
                  iconColor: const Color(0xFFE08E36),
                  iconBackground: const Color(0xFFFDECDA),
                  onTap: () => widget.onTabChange(3),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _metricCard(
                  value: data['availableRequests'] ?? 0,
                  label: 'طلبات جديدة بانتظارك',
                  icon: Icons.assignment_outlined,
                  iconColor: const Color(0xFF6A5AE0),
                  iconBackground: const Color(0xFFEFE9F5),
                  onTap: () => widget.onTabChange(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          DesignerGlassCard(
            padding: const EdgeInsets.all(20),
            borderRadius: 24,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF4D9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star, color: Color(0xFFFFB300)),
                ),
                const SizedBox(width: 14),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: _starRating(rating)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'تقييمي',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$ratingCount تقييم',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _profileCard(profile, portfolio),
          const SizedBox(height: 30),
          _sectionTitle('آخر النشاطات'),
          const SizedBox(height: 14),
          if (notifications.isEmpty)
            _emptyCard('لا توجد نشاطات أو إشعارات حتى الآن')
          else
            ...notifications.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _activityCard(entry.value, entry.key),
              ),
            ),
          const SizedBox(height: 18),
          _sectionTitle('آخر التقييمات'),
          const SizedBox(height: 14),
          if (reviews.isEmpty)
            _emptyCard('لا توجد تقييمات حقيقية حتى الآن')
          else
            ...reviews.map(_reviewCard),
        ],
      ),
    );
  }

  Widget _metricCard({
    required Object value,
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: DesignerGlassCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(height: 12),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileCard(
    Map<String, dynamic> profile,
    List<Map<String, dynamic>> portfolio,
  ) {
    final avatarUrl = profile['avatarUrl']?.toString();
    final images = portfolio
        .expand((item) => item['images'] as List<dynamic>? ?? const [])
        .map((image) => image.toString())
        .where((image) => image.isNotEmpty)
        .take(4)
        .toList();

    return DesignerGlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 145,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: images.isEmpty
                      ? Image.asset(
                          'assets/images/evening.png',
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/evening.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  left: 16,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 29,
                        backgroundColor: Colors.white30,
                        backgroundImage: avatarUrl == null
                            ? null
                            : NetworkImage(avatarUrl),
                        child: avatarUrl == null
                            ? const Icon(
                                Icons.person_outline,
                                color: Colors.white,
                                size: 32,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile['displayName']?.toString() ?? 'مصمم',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'مصمم • ${profile['city']?.toString().isNotEmpty == true ? profile['city'] : 'لم تحدد المدينة'}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile['bio']?.toString().isNotEmpty == true
                      ? profile['bio'].toString()
                      : 'أضف نبذة عن خبرتك وأعمالك من الملف الشخصي.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'معرض الأعمال',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => widget.onTabChange(1),
                      child: const Text('إدارة أعمالي ←'),
                    ),
                  ],
                ),
                if (images.isEmpty)
                  const Text(
                    'لم تضف أعمالًا إلى محفظتك حتى الآن',
                    style: TextStyle(color: AppColors.textMuted),
                  )
                else
                  SizedBox(
                    height: 76,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, index) => ClipOval(
                        child: Image.network(
                          images[index],
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 72,
                            height: 72,
                            color: Colors.black12,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityCard(Map<String, dynamic> activity, int index) {
    final cardColor = index.isEven
        ? const Color(0xFFEFF6FF).withOpacity(0.65)
        : const Color(0xFFFFF7ED).withOpacity(0.65);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: cardColor,
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.notifications_none,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['titleAr']?.toString() ?? 'إشعار جديد',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (activity['bodyAr']?.toString().isNotEmpty == true)
                      Text(
                        activity['bodyAr'].toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              if (activity['readAt'] == null)
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6A5AE0),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reviewCard(Map<String, dynamic> review) {
    final customer = review['customer'] as Map<String, dynamic>?;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DesignerGlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        child: Row(
          children: [
            const Icon(Icons.star, color: Color(0xFFFFB300)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer?['displayName']?.toString() ?? 'عميل',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    review['comment']?.toString().isNotEmpty == true
                        ? review['comment'].toString()
                        : 'بدون تعليق',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text('${review['rating']} / 5'),
          ],
        ),
      ),
    );
  }

  Widget _emptyCard(String message) => DesignerGlassCard(
    padding: const EdgeInsets.all(20),
    borderRadius: 20,
    child: Center(
      child: Text(message, style: const TextStyle(color: AppColors.textMuted)),
    ),
  );

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: AppColors.textDark,
    ),
  );

  Widget _starRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        final value = index + 1;
        if (rating >= value) {
          return const Icon(Icons.star, color: Color(0xFFFFB300), size: 16);
        }
        if (rating > index) {
          return const Icon(
            Icons.star_half,
            color: Color(0xFFFFB300),
            size: 16,
          );
        }
        return const Icon(
          Icons.star_border,
          color: AppColors.textMuted,
          size: 16,
        );
      }),
    );
  }

  Future<void> _showNotifications() async {
    final data = await _dashboard;
    if (!mounted) return;
    final notifications =
        (data['recentNotifications'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'الإشعارات',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (notifications.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(child: Text('لا توجد إشعارات حتى الآن')),
                )
              else
                ...notifications.map(
                  (notification) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.notifications_none),
                    title: Text(notification['titleAr']?.toString() ?? 'إشعار'),
                    subtitle: Text(notification['bodyAr']?.toString() ?? ''),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
