import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/models.dart';
import 'my_profile.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String title;
  final String? initialMessage;
  const ChatScreen({super.key, required this.roomId, required this.title, this.initialMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  List<DirectMessage> _msgs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _startAutoRefresh();
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      _controller.text = widget.initialMessage!;
      _sendMessage();
    }
  }

  Future<void> _startAutoRefresh() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3)); // 3초 주기
      if (mounted) {
        debugPrint('[Chat] Auto-fetching messages for room: ${widget.roomId}');
        await _fetchMessages();
      }
    }
  }

  Future<void> _fetchMessages() async {
    try {
      debugPrint('[Chat] Fetching messages from: ${ApiClient.baseUrl}/talks/${widget.roomId}/chats');
      final msgs = await ApiClient.fetchDirectMessages(widget.roomId);
      debugPrint('[Chat] Received ${msgs.length} messages');
      if (mounted) {
        setState(() {
          _msgs = msgs;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('[Chat] Error fetching messages: $e');
      if (mounted) {
        setState(() { _loading = false; });
      }
    }
  }

  Future<void> _sendMessage() async {
    final t = _controller.text.trim();
    if (t.isEmpty) return;
    try {
      debugPrint('[Chat] Sending message: "$t" to room: ${widget.roomId}');
      await ApiClient.sendDirectMessage(widget.roomId, t);
      debugPrint('[Chat] Message sent successfully');
      _controller.clear();
      await Future.delayed(const Duration(milliseconds: 500));
      await _fetchMessages();
    } catch (e) {
      debugPrint('[Chat] Error sending message: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        actions: const [Padding(
          padding: EdgeInsets.only(right: 8),
          child: Icon(Icons.more_vert, color: Colors.white),
        )],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: Colors.grey[500], borderRadius: BorderRadius.circular(8)),
            child: const Text('Tip. 대화중인 쪽지를 삭제하면 상대방의 쪽지도 삭제됩니다.',
              style: TextStyle(color: Colors.white)),
          ),
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: _msgs.length,
                  itemBuilder: (_, i) {
                    final m = _msgs[i];
                    return Align(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Text(m.body),
                      ),
                    );
                  },
                ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_a_photo),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyProfileScreen(),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: '메시지 입력…',
                        isDense: true,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    color: Colors.redAccent,
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
