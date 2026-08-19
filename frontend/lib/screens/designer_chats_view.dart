import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/designer_app_background.dart';
import 'designer_chat_room_screen.dart';

class DesignerChatsView extends StatelessWidget {
  const DesignerChatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> chats = [
      {
        'id': '1',
        'name': 'منى القحطاني',
        'avatar': 'https://randomuser.me/api/portraits/women/44.jpg',
        'lastMessage': 'هل يمكن تغيير اللون للبوردو؟',
        'product': 'فستان سهرة احترافي',
        'time': 'منذ ٥ د',
        'unread': 2,
      },
      {
        'id': '2',
        'name': 'ليلى الخالدي',
        'avatar': 'https://randomuser.me/api/portraits/women/68.jpg',
        'lastMessage': 'شكراً، متى يصل الطلب؟',
        'product': 'فستان سهرة ذهبي',
        'time': 'منذ ١ س',
        'unread': 1,
      },
      {
        'id': '3',
        'name': 'سارة الحربي',
        'avatar': 'https://randomuser.me/api/portraits/women/17.jpg',
        'lastMessage': 'الفستان رائع جداً، شكراً!',
        'product': 'فستان زفاف مميز',
        'time': 'أمس',
        'unread': 0,
      },
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'المحادثات',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: DesignerAppBackground(
          child: SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: chats.length,
              separatorBuilder: (context, index) => Divider(color: AppColors.textMuted.withOpacity(0.1), height: 1),
              itemBuilder: (context, index) {
                final chat = chats[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DesignerChatRoomScreen(chatData: chat),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage(chat['avatar']),
                            ),
                            if (chat['unread'] > 0)
                              Positioned(
                                top: -4,
                                left: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2E1B3D),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${chat['unread']}',
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chat['name'],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                chat['lastMessage'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: chat['unread'] > 0 ? AppColors.textDark : AppColors.textMuted,
                                  fontWeight: chat['unread'] > 0 ? FontWeight.bold : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text('👗 ', style: TextStyle(fontSize: 12)),
                                  Text(chat['product'], style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        Text(
                          chat['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: chat['unread'] > 0 ? const Color(0xFF2E1B3D) : AppColors.textMuted,
                            fontWeight: chat['unread'] > 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}