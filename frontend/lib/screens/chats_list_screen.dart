import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_background.dart';
import 'chat_detail_screen.dart';

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // mock data
    final List<Map<String, dynamic>> chats = [
      {'name': 'مها ديزاين', 'message': 'تم استلام طلبك، سأبدأ التصميم قريباً', 'time': '٩:٤١ ص', 'unread': 2, 'image': 'assets/images/evening dress designer.png'},
      {'name': 'نوف الأحمدي', 'message': 'هل يناسبك اللون الذهبي؟', 'time': 'أمس', 'unread': 0, 'image': 'assets/images/wedding dress designer.png'},
      {'name': 'خلود السالم', 'message': 'الفستان سيكون جاهز يوم الخميس', 'time': '٢ يوم', 'unread': 0, 'image': 'assets/imgages/party dress designer.png'},
      {'name': 'ليلى الزهراني', 'message': 'شكراً لاختيارك خدماتنا!', 'time': '٥ يوم', 'unread': 0, 'image': 'assets/images/splash_bg.jpg'},
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('المحادثات', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: AppBackground(
          child: SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: chats.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12, indent: 90),
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(chatData: chat)));
                  },
                  leading: Stack(
                    children: [
                      CircleAvatar(radius: 28, backgroundImage: AssetImage(chat['image'])),
                      if (chat['unread'] > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Color(0xFF8B6B78), shape: BoxShape.circle),
                            child: Text(
                              '${chat['unread']}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(chat['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  subtitle: Text(chat['message'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
                  trailing: Text(chat['time'], style: TextStyle(fontSize: 12, color: chat['unread'] > 0 ? const Color(0xFF8B6B78) : AppColors.textMuted)),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}