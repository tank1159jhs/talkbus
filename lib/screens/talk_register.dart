import 'package:flutter/material.dart';
import '../api/api_client.dart';

class TalkRegisterScreen extends StatefulWidget {
  const TalkRegisterScreen({super.key});

  @override
  State<TalkRegisterScreen> createState() => _TalkRegisterScreenState();
}

class _TalkRegisterScreenState extends State<TalkRegisterScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  void _submitTalk() async {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) return;
    try {
      final post = await ApiClient.createTalkPost(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, post);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 등록 실패: $e')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text('토크 등록', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '제목'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: '내용'),
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitTalk,
              child: const Text('등록'),
            ),
          ],
        ),
      ),
    );
  }
}
