import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/models.dart';
import 'chat.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<DirectRoom> _rooms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    try {
      final rooms = await ApiClient.fetchDirectRooms();
      setState(() {
        _rooms = rooms;
        _loading = false;
      });
    } catch (e) {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text('쪽지', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _rooms.length,
            itemBuilder: (context, index) {
              final room = _rooms[index];
              return ListTile(
                title: Text('채팅방: ${room.id}'),
                subtitle: Text('생성일: ${room.createdAt.toLocal()}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        roomId: room.id,
                        title: '채팅방',
                      ),
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}
