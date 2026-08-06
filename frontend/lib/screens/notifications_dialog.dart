import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// دالة جاهزة تستدعيها من أي مكان لفتح الإشعارات
void showNotificationsDialog(BuildContext context) {
  showDialog(
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
  // البيانات (isRead تحدد هل هو مقروء أو لا)
  List<Map<String, dynamic>> notifications = [
    {'title': 'نوف الأحمدي قبلت طلبك', 'sub': 'فستان سهرة ذهبي', 'time': 'منذ ٥ د', 'icon': Icons.star, 'iconColor': Colors.black87, 'isRead': false},
    {'title': 'طلبك رقم #2341 قيد التجهيز', 'sub': 'تحديث حالة الطلب', 'time': 'منذ ٣٠ د', 'icon': Icons.inventory_2, 'iconColor': Colors.brown, 'isRead': false},
    {'title': 'رسالة جديدة من مها الحربي', 'sub': 'هل يمكن تغيير الموعد؟', 'time': 'منذ ١ س', 'icon': Icons.chat_bubble, 'iconColor': Colors.purpleAccent, 'isRead': false},
    {'title': 'تم إكمال تصميمك!', 'sub': 'فستان الزفاف الملكي جاهز', 'time': 'أمس', 'icon': Icons.celebration, 'iconColor': Colors.redAccent, 'isRead': true}, // مقروء سابقاً
    {'title': 'قيّمي مصممتك', 'sub': 'شاركي تجربتك مع سارة الشمري', 'time': '٢ يوم', 'icon': Icons.star_border, 'iconColor': Colors.orange, 'isRead': true},
  ];

  int get unreadCount => notifications.where((n) => n['isRead'] == false).length;

  void _markAllAsRead() {
    setState(() {
      for (var n in notifications) {
        n['isRead'] = true;
      }
    });
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
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      // 💡 هنا يتغير اللون، إذا مقروء يصير شفاف 50%
                      return Opacity(
                        opacity: notif['isRead'] ? 0.6 : 1.0, 
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
                                child: Icon(notif['icon'], color: notif['iconColor'], size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(notif['title'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                                    Text(notif['sub'], style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  ],
                                ),
                              ),
                              Text(notif['time'], style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
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