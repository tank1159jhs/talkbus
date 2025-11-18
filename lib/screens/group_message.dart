import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/models.dart';

class GroupMessageScreen extends StatefulWidget {
  final String groupRoomId;
  final String title;
  const GroupMessageScreen({super.key, required this.groupRoomId, required this.title});

  @override
  State<GroupMessageScreen> createState() => _GroupMessageScreenState();
}

class _GroupMessageScreenState extends State<GroupMessageScreen> {
  final _controller = TextEditingController();
  List<GroupMessage> _msgs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _joinGroupAndFetchMessages();
    _startAutoRefresh();
  }

  Future<void> _joinGroupAndFetchMessages() async {
    try {
      // 그룹에 자동으로 참가
      debugPrint('[GroupMessage] Joining group: ${widget.groupRoomId}');
      await ApiClient.joinGroup(widget.groupRoomId);
      debugPrint('[GroupMessage] Successfully joined group');
      // 메시지 로드
      await _fetchMessages();
    } catch (e) {
      debugPrint('[GroupMessage] Error joining group: $e');
      if (mounted) {
        setState(() { _loading = false; });
      }
    }
  }

  Future<void> _startAutoRefresh() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3)); // 3초로 증가 (DB 부하 감소)
      if (mounted) {
        debugPrint('[GroupMessage] Auto-fetching messages for group: ${widget.groupRoomId}');
        await _fetchMessages();
      }
    }
  }

  Future<void> _fetchMessages() async {
    try {
      debugPrint('[GroupMessage] Fetching messages from: ${ApiClient.baseUrl}/groups/${widget.groupRoomId}/messages');
      final msgs = await ApiClient.fetchGroupMessages(widget.groupRoomId);
      debugPrint('[GroupMessage] Received ${msgs.length} messages');
      if (mounted) {
        setState(() {
          _msgs = msgs;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('[GroupMessage] Error fetching messages: $e');
      if (mounted) {
        setState(() { _loading = false; });
      }
    }
  }

  Future<void> _sendMessage() async {
    final t = _controller.text.trim();
    if (t.isEmpty) return;
    try {
      debugPrint('[GroupMessage] Sending message to group: ${widget.groupRoomId}');
      await ApiClient.sendGroupMessage(widget.groupRoomId, t);
      _controller.clear();
      await Future.delayed(const Duration(milliseconds: 500));
      await _fetchMessages();
    } catch (e) {
      debugPrint('[GroupMessage] Error sending message: $e');
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
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: _msgs.length,
                  itemBuilder: (_, i) {
                    final m = _msgs[i];
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 작성자 이름 (있으면 표시)
                            if (m.author != null)
                              Text(
                                m.author!.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            const SizedBox(height: 4),
                            // 메시지 본문
                            Text(m.body),
                          ],
                        ),
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
                  IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
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
