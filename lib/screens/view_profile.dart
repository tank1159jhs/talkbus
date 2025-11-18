import 'package:flutter/material.dart';

class ViewProfileScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  const ViewProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final String title   = user['title'] ?? '프로필';
    final String intro   = user['intro'] ?? '';
    final String gender  = user['gender'] ?? 'unknown';
    final int?   age     = user['age'];
    final int    likes   = user['likes'] ?? 0;
    final int    distance= user['distance'] ?? 0;
    final String? image  = user['image'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text('프로필 페이지', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.grid_view_rounded, color: Colors.white),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 56,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Icon(Icons.favorite_border),
              Icon(Icons.star_border),
              Icon(Icons.chat_bubble_outline),
              Icon(Icons.image_outlined),
              Icon(Icons.block),
              Icon(Icons.notifications_none),
            ],
          ),
        ),
      ),
      body: ListView(
        children: [
          // 상단 이미지 영역
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: image == null
                    ? Container(color: Colors.black12)
                    : Image.asset('assets/images/profile_placeholder.png', fit: BoxFit.cover),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('1/2', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          // 기본 정보 (이름/성별/나이/거리/좋아요)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(title,
                            style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        if (gender == 'female')
                          const Icon(Icons.female, color: Colors.pinkAccent, size: 18)
                        else if (gender == 'male')
                          const Icon(Icons.male, color: Colors.blueAccent, size: 18),
                        if (age != null) ...[
                          const SizedBox(width: 4),
                          Text('$age', style: const TextStyle(color: Colors.grey)),
                        ],
                      ]),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('지금, ${distance}m',
                              style: const TextStyle(color: Colors.grey)),
                          const SizedBox(width: 12),
                          const Icon(Icons.favorite, size: 16, color: Colors.pink),
                          const SizedBox(width: 4),
                          Text('$likes', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 상세 텍스트 섹션
          _kvRow('Theme', title),
          _kvRow('Message', intro.isEmpty ? ' ' : intro),
          _kvRow('Introduce', '🙂🙂'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _kvRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 90,
              child: Text(key,
                  style: const TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}