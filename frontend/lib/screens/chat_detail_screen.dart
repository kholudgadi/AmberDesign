import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_background.dart';

class ChatDetailScreen extends StatefulWidget {
  final Map<String, dynamic> chatData;

  const ChatDetailScreen({super.key, required this.chatData});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  
  // Virtual messages
  final List<Map<String, dynamic>> _messages = [
    {'text': 'أهلاً! تم استلام طلبك بنجاح 🎉', 'isMe': false, 'time': '٩:٣٠ ص'},
    {'text': 'شكراً جزيلاً، متى تتوقعين الانتهاء؟', 'isMe': true, 'time': '٩:٣٥ ص'},
    {'text': 'تم استلام طلبك، سأبدأ التصميم قريباً', 'isMe': false, 'time': '٩:٤١ ص'},
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'text': _controller.text.trim(),
        'isMe': true,
        'time': 'الآن',
      });
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_forward, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 16, backgroundImage: AssetImage(widget.chatData['image'])),
              const SizedBox(width: 10),
              Text(widget.chatData['name'], style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: Colors.black12, height: 1.0),
          ),
        ),
        body: AppBackground(
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildMessageBubble(msg['text'], msg['isMe'], msg['time']);
                    },
                  ),
                ),
                _buildMessageInput(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight, // You on left, the other one on right
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? Colors.white.withOpacity(0.5) : const Color(0xFF322336), 
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 0 : 20),
            bottomRight: Radius.circular(isMe ? 20 : 0),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(text, style: TextStyle(fontSize: 15, color: isMe ? AppColors.textDark : Colors.white)),
            const SizedBox(height: 4),
            Text(time, style: TextStyle(fontSize: 10, color: isMe ? AppColors.textMuted : Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white.withOpacity(0.3),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(25)),
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: AppColors.textDark),
                    decoration: const InputDecoration(hintText: 'اكتبي رسالتك...', border: InputBorder.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Color(0xFF322336), shape: BoxShape.circle),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}