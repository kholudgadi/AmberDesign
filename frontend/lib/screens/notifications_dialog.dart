import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/designer_service.dart';
import '../utils/app_colors.dart';

// دالة جاهزة تستدعيها من أي مكان لفتح الإشعارات
Future<void> showNotificationsDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.3),
    builder: (context) => const Directionality(
      textDirection: TextDirection.rtl,
      child: _NotificationsContent(),
    ),
  );
}

class _NotificationsContent extends StatefulWidget {
  const _NotificationsContent();

  @override
  State<_NotificationsContent> createState() => _NotificationsContentState();
}

class _NotificationsContentState extends State<_NotificationsContent> {
  List<Map<String, dynamic>> notifications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await DesignerService.instance.notifications();
      if (mounted) setState(() => notifications = result);
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذر تحميل الإشعارات');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get unreadCount => notifications.where((n) => n['readAt'] == null).length;

  Future<void> _markAllAsRead() async {
    final unread = notifications.where((item) => item['readAt'] == null).toList();
    await Future.wait(unread.map((item) => DesignerService.instance.markNotificationRead(item['id'].toString())));
    if (mounted) setState(() {
      for (final item in notifications) {
        item['readAt'] ??= DateTime.now().toIso8601String();
      }
    });
  }

  String _time(dynamic value) {
    final created = DateTime.tryParse(value?.toString() ?? '');
    if (created == null) return '';
    final difference = DateTime.now().difference(created.toLocal());
    if (difference.inMinutes < 60) return 'منذ ${difference.inMinutes} د';
    if (difference.inHours < 24) return 'منذ ${difference.inHours} س';
    return 'منذ ${difference.inDays} ي';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            color: const Color(0xFFF7F2EE).withOpacity(0.95), // لون مقارب للتصميم
            child: Column(
              children: [
                // الهيدر
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Text('الإشعارات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      const SizedBox(width: 8),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Color(0xFF8B6B78), shape: BoxShape.circle),
                          child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.close, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                ),
                
                // قائمة الإشعارات
                Expanded(
                  child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(child: Text(_error!))
                    : notifications.isEmpty
                    ? const Center(child: Text('لا توجد إشعارات'))
                    : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      // 💡 هنا يتغير اللون، إذا مقروء يصير شفاف 50%
                      return Opacity(
                        opacity: notif['readAt'] != null ? 0.6 : 1.0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                child: const Icon(Icons.notifications_outlined, color: AppColors.textDark, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(notif['titleAr']?.toString() ?? notif['titleEn']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                                    Text(notif['bodyAr']?.toString() ?? notif['bodyEn']?.toString() ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  ],
                                ),
                              ),
                              Text(_time(notif['createdAt']), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // زر تحديد الكل (تم حل مشكلة الـ Padding هنا 💡)
                TextButton(
                  onPressed: unreadCount > 0 ? _markAllAsRead : null,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(24), // الطريقة الصحيحة في فلاتر
                  ),
                  child: Text(
                    'تحديد الكل كمقروء',
                    style: TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.bold, 
                      color: unreadCount > 0 ? AppColors.textDark : AppColors.textMuted.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
