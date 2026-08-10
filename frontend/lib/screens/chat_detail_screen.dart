import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../utils/app_colors.dart';
import '../widgets/app_background.dart';

class ChatDetailScreen extends StatefulWidget {
  final String conversationId;
  final Map<String, dynamic> participant;

  const ChatDetailScreen({super.key, required this.conversationId, required this.participant});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _controller = TextEditingController();
  late Future<({String userId, List<Map<String, dynamic>> messages})> _data;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _data = () async {
      final results = await Future.wait([
        AuthService.instance.currentUser(),
        ChatService.instance.messages(widget.conversationId),
      ]);
      return (userId: (results[0] as Map<String, dynamic>)['id'].toString(), messages: results[1] as List<Map<String, dynamic>>);
    }();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ChatService.instance.send(widget.conversationId, text);
      _controller.clear();
      setState(_reload);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: Text(widget.participant['displayName']?.toString() ?? 'المحادثة')),
      body: AppBackground(
        child: SafeArea(child: Column(children: [
          Expanded(child: FutureBuilder<({String userId, List<Map<String, dynamic>> messages})>(
            future: _data,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return const Center(child: Text('تعذر تحميل الرسائل'));
              final data = snapshot.data!;
              if (data.messages.isEmpty) return const Center(child: Text('لا توجد رسائل، ابدأ المحادثة الآن'));
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: data.messages.length,
                itemBuilder: (_, index) {
                  final message = data.messages[index];
                  final mine = message['senderId'].toString() == data.userId;
                  return Align(
                    alignment: mine ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .72),
                      decoration: BoxDecoration(
                        color: mine ? Colors.white.withOpacity(.65) : AppColors.textDark,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(message['text']?.toString() ?? '', style: TextStyle(color: mine ? AppColors.textDark : Colors.white)),
                    ),
                  );
                },
              );
            },
          )),
          Container(
            padding: const EdgeInsets.all(14),
            color: Colors.white.withOpacity(.45),
            child: Row(children: [
              Expanded(child: TextField(controller: _controller, onSubmitted: (_) => _send(), decoration: const InputDecoration(hintText: 'اكتب رسالتك...', border: OutlineInputBorder()))),
              const SizedBox(width: 10),
              IconButton(onPressed: _sending ? null : _send, icon: _sending ? const CircularProgressIndicator() : const Icon(Icons.send)),
            ]),
          ),
        ])),
      ),
    ),
  );
}
