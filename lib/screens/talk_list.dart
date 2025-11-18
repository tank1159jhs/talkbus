import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/models.dart';
import 'message.dart';
import 'my_profile.dart';

class TalkListScreen extends StatefulWidget {
  const TalkListScreen({super.key});

  @override
  State<TalkListScreen> createState() => _TalkListScreenState();
}

class _TalkListScreenState extends State<TalkListScreen> {
  List<TalkPost> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      final posts = await ApiClient.fetchTalkPosts();
      setState(() {
        _posts = posts;
        _loading = false;
      });
    } catch (e) {
      setState(() { _loading = false; });
    }
  }

  void _showDmDialog(BuildContext context, TalkPost post) {
    final TextEditingController _dmController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('DM 보내기'),
          content: TextField(
            controller: _dmController,
            decoration: const InputDecoration(hintText: '메시지를 입력하세요'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                // DM 전송: 쪽지방 생성 및 쪽지 메시지 전송 후 쪽지 리스트(MessageScreen)로 이동
                final myId = await ApiClient.getCurrentUserId();
                if (myId == null) return;
                final room = await ApiClient.createDirectRoom(
                  userAId: myId,
                  userBId: post.authorId,
                );
                // 메시지 전송
                final msg = _dmController.text.trim();
                if (msg.isNotEmpty) {
                  await ApiClient.sendDirectMessage(room.id, msg);
                }
                if (!mounted) return;
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MessageScreen(),
                  ),
                );
              },
              child: const Text('전송'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text('토크 게시판', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              final post = _posts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 2,
                color: Colors.redAccent.withAlpha(13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyProfileScreen(userId: post.authorId),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: post.authorProfileUrl != null && post.authorProfileUrl!.isNotEmpty
                              ? NetworkImage(post.authorProfileUrl!)
                              : null,
                          child: (post.authorProfileUrl == null || post.authorProfileUrl!.isEmpty)
                              ? const Icon(Icons.person, size: 28)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (post.authorGender != null)
                                    Icon(
                                      post.authorGender == 'female' ? Icons.female : Icons.male,
                                      color: post.authorGender == 'female' ? Colors.pink : Colors.blue,
                                      size: 16,
                                    ),
                                  const SizedBox(width: 4),
                                  Text(post.authorId.substring(0, 6), style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                post.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                post.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.message, color: Colors.redAccent),
                              tooltip: 'DM 보내기',
                              onPressed: () => _showDmDialog(context, post),
                            ),
                            if (post.authorId == ApiClient.currentUserId)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: '삭제',
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('삭제 확인'),
                                      content: const Text('이 토크를 삭제하시겠습니까?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('취소'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('삭제'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await ApiClient.deleteTalkPost(post.id);
                                    _fetchPosts();
                                  }
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/talkRegister');
          if (result != null) _fetchPosts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
