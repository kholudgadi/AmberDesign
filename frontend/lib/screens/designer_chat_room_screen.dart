import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/designer_app_background.dart';
import 'designer_order_details_screen.dart'; 

class DesignerChatRoomScreen extends StatefulWidget {
  final Map<String, dynamic> chatData;

  const DesignerChatRoomScreen({super.key, required this.chatData});

  @override
  State<DesignerChatRoomScreen> createState() => _DesignerChatRoomScreenState();
}

class _DesignerChatRoomScreenState extends State<DesignerChatRoomScreen> {
  final TextEditingController _messageCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {'text': 'هل يمكن تغيير اللون للبوردو؟', 'isMe': false, 'time': '٢:١٠ م'},
    {'text': 'أهلاً! بالتأكيد، هذا ممكن.', 'isMe': true, 'time': '٢:١٢ م'},
    {'text': 'ممتاز! وهل يمكن إضافة تطريز على الأكمام؟', 'isMe': false, 'time': '٢:١٤ م'},
    {'text': 'نعم يمكن، سيضاف ٢٠٠ ر.س إضافية.', 'isMe': true, 'time': '٢:١٥ م'},
    {'text': 'موافقة، تفضلي بالمتابعة 🙏', 'isMe': false, 'time': '٢:١٦ م'},
  ];

  void _sendMessage() {
    if (_messageCtrl.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': _messageCtrl.text.trim(),
        'isMe': true,
        'time': 'الآن',
      });
    });

    _messageCtrl.clear();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFBF9F6), 
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(widget.chatData['avatar']),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.chatData['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  Text(widget.chatData['product'], style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: ElevatedButton(
                onPressed: () {
                  final mockOrder = {
                    'title': widget.chatData['product'] ?? 'طلب تصميم',
                    'clientName': widget.chatData['name'] ?? 'العميل',
                    'clientAvatar': widget.chatData['avatar'] ?? 'https://randomuser.me/api/portraits/women/44.jpg',
                    'status': 'قيد التنفيذ', 
                    'price': '٢٤٠٠ ر.س',
                    'image': 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=200&auto=format&fit=crop', 
                    'currentStep': 3, 
                    'date': 'اليوم، 10:30 ص',
                  };

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DesignerOrderDetailsScreen(order: mockOrder),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('عرض الطلب', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            )
          ],
        ),
        body: DesignerAppBackground(
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildMessageBubble(msg['text'], msg['isMe'], msg['time']);
                    },
                  ),
                ),
                _buildInputArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF2E1B3D) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomRight: Radius.circular(isMe ? 20 : 0), 
            bottomLeft: Radius.circular(isMe ? 0 : 20),  
          ),
          boxShadow: [
            if (!isMe) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: isMe ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: isMe ? Colors.white.withOpacity(0.6) : AppColors.textMuted.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 12),
      color: Colors.transparent,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ميزة إرفاق الملفات')));
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.file_upload_outlined, color: AppColors.textMuted, size: 26),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: TextField(
                controller: _messageCtrl,
                style: const TextStyle(color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'اكتبي رسالة...',
                  hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.6)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),

          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(color: Color(0xFF2E1B3D), shape: BoxShape.circle),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}