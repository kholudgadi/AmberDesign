import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class DesignerNotificationsSheet extends StatefulWidget {
  const DesignerNotificationsSheet({super.key});

  @override
  State<DesignerNotificationsSheet> createState() => _DesignerNotificationsSheetState();
}

class _DesignerNotificationsSheetState extends State<DesignerNotificationsSheet> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'title': 'طلب تصميم جديد من سارة!',
      'subtitle': 'فستان زفاف ملكي - طلب #٤٠٩٢',
      'time': 'منذ ٥ د',
      'icon': Icons.inventory_2_outlined,
      'iconColor': const Color(0xFFE08E36),
      'bgColor': const Color(0xFFFDECDA),
      'isRead': false,
    },
    {
      'id': 2,
      'title': 'رسالة جديدة من العميلة نوف',
      'subtitle': 'هل يمكننا تعديل درجة اللون الذهبي؟',
      'time': 'منذ ١٥ د',
      'icon': Icons.chat_bubble_outline,
      'iconColor': const Color(0xFF1976D2),
      'bgColor': const Color(0xFFE3F2FD),
      'isRead': false,
    },
    {
      'id': 3,
      'title': 'تمت الموافقة على التصميم',
      'subtitle': 'العميلة ريم وافقت على السكيتش المبدئي',
      'time': 'منذ ساعتين',
      'icon': Icons.check_circle_outline,
      'iconColor': const Color(0xFF388E3C),
      'bgColor': const Color(0xFFE8F5E9),
      'isRead': true,
    },
    {
      'id': 4,
      'title': 'تم استلام الدفعة الأولى',
      'subtitle': 'تم تحويل ١٢٠٠ ر.س لمحفظتك لطلب #٤٠٥٠',
      'time': 'أمس',
      'icon': Icons.account_balance_wallet_outlined,
      'iconColor': const Color(0xFF6A5AE0),
      'bgColor': const Color(0xFFEFE9F5),
      'isRead': true,
    },
    {
      'id': 5,
      'title': 'تقييم ٥ نجوم جديد! ⭐',
      'subtitle': 'العميلة لمياء تركت تقييماً رائعاً لعملك',
      'time': 'منذ يومين',
      'icon': Icons.star_border,
      'iconColor': const Color(0xFFFFB300),
      'bgColor': const Color(0xFFFFF4D9),
      'isRead': true,
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
  }

  void _markAsRead(int index) {
    if (!_notifications[index]['isRead']) {
      setState(() {
        _notifications[index]['isRead'] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !(n['isRead'] as bool)).length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85, 
        decoration: const BoxDecoration(
          color: Color(0xFFFBF9F6), 
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'الإشعارات',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF906A8B), 
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, height: 1),
                          ),
                        ),
                      ]
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.textMuted.withOpacity(0.1), height: 1),

            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: _notifications.length,
                separatorBuilder: (context, index) => Divider(color: AppColors.textMuted.withOpacity(0.1), height: 1),
                itemBuilder: (context, index) {
                  final item = _notifications[index];
                  final bool isRead = item['isRead'];

                  return InkWell(
                    onTap: () => _markAsRead(index),
                    child: Container(
                      color: isRead ? Colors.transparent : Colors.white.withOpacity(0.6), 
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: item['bgColor'],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))
                              ],
                            ),
                            child: Icon(item['icon'], color: item['iconColor'], size: 20),
                          ),
                          const SizedBox(width: 16),
                          
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'],
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['subtitle'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                    fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['time'],
                                  style: TextStyle(fontSize: 11, color: AppColors.textMuted.withOpacity(0.8)),
                                ),
                              ],
                            ),
                          ),
                          
                          if (!isRead)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E1B3D),
                                shape: BoxShape.circle,
                              ),
                            )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            if (unreadCount > 0) ...[
              Divider(color: AppColors.textMuted.withOpacity(0.1), height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: TextButton(
                  onPressed: _markAllAsRead,
                  child: const Text(
                    'تحديد الكل كمقروء',
                    style: TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}