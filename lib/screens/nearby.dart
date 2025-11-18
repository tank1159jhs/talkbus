// nearby_screen.dart
import 'package:flutter/material.dart';
import 'view_profile.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> sortedUsers = List.from(nearbyUsers);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        if (_tabController.index == 0) {
          // 최근순 (기본 그대로)
          sortedUsers = List.from(nearbyUsers);
        } else if (_tabController.index == 1) {
          // 가까운순
          sortedUsers = List.from(nearbyUsers)
            ..sort((a, b) => a['distance'].compareTo(b['distance']));
        } else if (_tabController.index == 2) {
          // 인기순 (likes 많은 순)
          sortedUsers = List.from(nearbyUsers)
            ..sort((b, a) => a['likes'].compareTo(b['likes']));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text('주변', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white, // 선택된 탭 글씨색
          unselectedLabelColor: Colors.white70, // 선택 안된 탭 글씨색
          tabs: const [
            Tab(text: '최근순'),
            Tab(text: '가까운순'),
            Tab(text: '인기순'),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: sortedUsers.length,
        itemBuilder: (context, index) {
          final user = sortedUsers[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: 28,
                backgroundImage: user['image'] != null
                    ? AssetImage(user['image'] as String)
                    : null,
                child: user['image'] == null
                    ? const Icon(Icons.person, size: 28)
                    : null,
              ),
              title: Text(
                user['title'] as String? ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    user['intro'] as String? ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        user['gender'] == 'female'
                            ? Icons.female
                            : Icons.male,
                        color: user['gender'] == 'female'
                            ? Colors.pink
                            : Colors.blue,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text('${user['age']}세'),
                      const SizedBox(width: 8),
                      const Icon(Icons.favorite, color: Colors.red, size: 16),
                      const SizedBox(width: 2),
                      Text('${user['likes']}'),
                      const SizedBox(width: 8),
                      const Icon(Icons.location_on,
                          color: Colors.grey, size: 16),
                      const SizedBox(width: 2),
                      Text('${user['distance']}m'),
                    ],
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ViewProfileScreen(user: user),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

final List<Map<String, dynamic>> nearbyUsers = [
  {
    'title': '같이 산책하실 분',
    'intro': '오늘 날씨 좋아요 ☀️ 산책하실 분 찾아요~',
    'gender': 'female',
    'age': 27,
    'likes': 12,
    'distance': 350,
    'image': 'assets/images/profile_placeholder.png',
  },
  {
    'title': '저녁 같이 드실 분',
    'intro': '근처 맛집 가실 분? 🍜',
    'gender': 'male',
    'age': 32,
    'likes': 5,
    'distance': 800,
    'image': null,
  },
  {
    'title': '커피 한잔 할래요?',
    'intro': '근처 카페 추천 받아요 ☕',
    'gender': 'female',
    'age': 25,
    'likes': 22,
    'distance': 120,
    'image': 'assets/images/profile_placeholder.png',
  },
];
