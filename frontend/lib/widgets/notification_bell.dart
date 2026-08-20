import 'package:flutter/material.dart';
import '../screens/notifications_dialog.dart';
import '../services/designer_service.dart';
import '../utils/app_colors.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    try {
      final notifications = await DesignerService.instance.notifications();
      final count = notifications.where((item) => item['readAt'] == null).length;
      if (mounted) setState(() => _unreadCount = count);
    } catch (_) {
      // The dialog itself displays API errors; the app bar stays usable.
    }
  }

  Future<void> _open() async {
    await showNotificationsDialog(context);
    await _loadCount();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'الإشعارات',
      onPressed: _open,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none, color: AppColors.textDark, size: 28),
          if (_unreadCount > 0)
            Positioned(
              top: -7,
              right: -9,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text(
                  _unreadCount > 99 ? '99+' : '$_unreadCount',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
