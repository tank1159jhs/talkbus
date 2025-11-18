import 'package:flutter/material.dart';
import 'talk_list.dart';
import 'nearby.dart';
import 'group.dart';
import 'message.dart';
import 'more.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    TalkListScreen(),
    NearbyScreen(),
    GroupScreen(),
    MessageScreen(),
    MoreScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '토크'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: '주변'),
          BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: '단체'),
          BottomNavigationBarItem(icon: Icon(Icons.mark_chat_unread), label: '쪽지'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: '더보기'),
        ],
      ),
    );
  }
}
