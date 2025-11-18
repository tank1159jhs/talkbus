import 'package:flutter/material.dart';
import 'my_profile.dart';
import 'point.dart';
import 'settings.dart';
import 'package:talkbus/api/api_client.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  // 메뉴 데이터만 추가/삭제하면 UI가 자동 반영됩니다.
  static const _menus = <_Menu>[
    _Menu(Icons.person_outline, '내 프로필'),
    _Menu(Icons.star_border, '즐겨찾기'),
    _Menu(Icons.monetization_on_outlined, '포인트'),
    _Menu(Icons.card_giftcard, '무료충전'),
    _Menu(Icons.check_circle_outline, '출석체크'),
    _Menu(Icons.lock_outline, '비밀사진'),
    _Menu(Icons.favorite_border, '하트'),
    _Menu(Icons.block, '차단 멤버'),
    _Menu(Icons.notifications, '공지사항'),
    _Menu(Icons.help_outline, 'FAQ'),
    _Menu(Icons.mail_outline, '문의하기'),
    _Menu(Icons.settings, '앱 설정'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text('더보기', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _push(context, const SettingsScreen()), // ✅ 바로 연결
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _menus.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12,
              ),
              itemBuilder: (context, i) {
                final m = _menus[i];
                return _MenuTile(menu: m, onTap: () => _open(context, m.label));
              },
            ),
          ),
        ],
      ),
    );
  }

  // 간단 라우팅: 제목으로 목적지 분기
  static void _open(BuildContext context, String title) async {
    if (title == '내 프로필') {
      final userId = await ApiClient.getCurrentUserId();
      if (userId != null) {
        return _push(context, MyProfileScreen(userId: userId));
      } else {
        // 로그인 정보 없을 때 예외 처리(임시)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 정보가 없습니다.')),
        );
        return;
      }
    }

    if (title == '포인트') {
      return _push(context, const PointScreen());
    }

    if (title == '앱 설정') {
      return _push(context, const SettingsScreen()); // ✅ 추가
    }

    // 나머지는 임시 화면
    _push(
      context,
      Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: Text(title, style: const TextStyle(color: Colors.white)),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(child: Text('$title 화면 (추후 연결)')),
      ),
    );
  }

  // 공용 네비게이션 헬퍼
  static void _push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _Menu {
  final IconData icon;
  final String label;
  const _Menu(this.icon, this.label);
}

class _MenuTile extends StatelessWidget {
  final _Menu menu;
  final VoidCallback onTap;
  const _MenuTile({required this.menu, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.redAccent.withAlpha(13),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(menu.icon, size: 28, color: Colors.redAccent),
            const SizedBox(height: 8),
            Text(
              menu.label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
