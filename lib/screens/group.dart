import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/models.dart';
import 'group_message.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  // 지역 드롭다운 (실데이터 기반, '전체' 포함)
  final List<String> _regions = const ['전체', '서울', '부산', '대구', '도쿄', '오사카'];
  String _region = '전체';

  // 정렬 드롭다운 (인기순/최신순)
  final List<String> _sortOptions = const ['인기순', '최신순'];
  String _sort = '인기순';

  // 카테고리 칩(실데이터 기반, '전체' 포함)
  final List<String> _cats = const ['전체', '잡담·일상', '취미·여가', '정보·노하우', '관계·연애', '이벤트·실시간'];
  String _cat = '전체';

  List<GroupRoom> _groups = [];
  bool _loading = true;
  String _search = '';

  List<GroupRoom> get filteredGroups {
    var list = _groups;
    // 검색어 필터
    if (_search.isNotEmpty) {
      list = list.where((g) => g.title.toLowerCase().contains(_search.toLowerCase())).toList();
    }
    // 정렬
    switch (_sort) {
      case '최신순':
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      default: // 인기순
        list.sort((a, b) => (b.memberships?.length ?? 0).compareTo(a.memberships?.length ?? 0));
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    try {
      final groups = await ApiClient.fetchGroupRooms();
      setState(() {
        _groups = groups;
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
        title: const Text('단체 톡방', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // 상단: 지역 & 정렬 드롭다운, 총 개수 표시
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 6, offset: const Offset(0,2))],
                ),
                child: Row(
                  children: [
                    const Text('지역', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _region,
                      items: _regions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (v) => setState(() => _region = v!),
                    ),
                    const SizedBox(width: 16),
                    const Text('정렬', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _sort,
                      items: _sortOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => _sort = v!),
                    ),
                    const Spacer(),
                    Text('총 ${filteredGroups.length}개', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              // 카테고리 칩
              SizedBox(
                height: 46,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: _cats.length,
                  itemBuilder: (_, i) {
                    final c = _cats[i];
                    final sel = _cat == c;
                    return ChoiceChip(
                      label: Text(c),
                      selected: sel,
                      onSelected: (_) => setState(() => _cat = c),
                      selectedColor: Colors.redAccent.withValues(alpha: .15),
                      labelStyle: TextStyle(color: sel ? Colors.redAccent : Colors.black87),
                      side: BorderSide(color: sel ? Colors.redAccent : const Color(0xFFE0E0E0)),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                ),
              ),
              // 검색
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: '그룹명 검색',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              // 리스트
              Expanded(
                child: ListView.builder(
                  itemCount: filteredGroups.length,
                  itemBuilder: (context, index) {
                    final group = filteredGroups[index];
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
                              builder: (_) => GroupMessageScreen(
                                groupRoomId: group.id,
                                title: group.title,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.redAccent.withAlpha(40),
                                child: const Icon(Icons.group, size: 28, color: Colors.redAccent),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      group.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('생성일: ${group.createdAt.toLocal()}'),
                                    const SizedBox(height: 2),
                                    Text('참가자: ${group.memberships?.length ?? 0}명', style: const TextStyle(color: Colors.blue)),
                                    // 최근 메시지 등 확장 가능
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final controller = TextEditingController();
          await showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text('새 그룹 생성'),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: '그룹명 입력'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('취소'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final groupName = controller.text.trim();
                      if (groupName.isEmpty) return;
                      try {
                        await ApiClient.createGroupRoom(title: groupName);
                        Navigator.pop(ctx);
                        await _fetchGroups(); // 리스트 갱신
                      } catch (e) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('그룹 생성 실패: ${e.toString()}')),
                        );
                      }
                    },
                    child: const Text('생성'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}