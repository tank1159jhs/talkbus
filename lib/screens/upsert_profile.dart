import 'package:flutter/material.dart';
import '../api/api_client.dart';
import 'home.dart';

class UpsertProfileScreen extends StatefulWidget {
  const UpsertProfileScreen({super.key});

  @override
  State<UpsertProfileScreen> createState() => _UpsertProfileScreenState();
}

class _UpsertProfileScreenState extends State<UpsertProfileScreen> {
  final nicknameController = TextEditingController();
  String? gender;
  DateTime? birthDate;
  String? topic;

  void _showDialog(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (nicknameController.text.isEmpty) return _showDialog("닉네임을 입력해주세요.");
    if (gender == null) return _showDialog("성별을 선택해주세요.");
    if (birthDate == null) return _showDialog("생년월일을 선택해주세요.");

    final res = await ApiClient.put("/users/update-profile", {
      "nickname": nicknameController.text,
      "gender": gender,
      "birthDate": birthDate!.toUtc().toIso8601String(),
      "topic": topic,
    });

    if (res.statusCode == 200) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
      }
    } else {
      _showDialog("프로필 저장 실패: ${res.body}");
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => birthDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("프로필 작성"),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _saveProfile)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: nicknameController,
              decoration: const InputDecoration(labelText: "닉네임 (2-10자)"),
            ),
            const SizedBox(height: 20),

            Wrap(
              spacing: 12,
              children: [
                for (var g in ["male:남자", "female:여자", "other:기타"])
                  ChoiceChip(
                    label: Text(g.split(":")[1]),
                    selected: gender == g.split(":")[0],
                    onSelected: (_) => setState(() => gender = g.split(":")[0]),
                  )
              ],
            ),
            const SizedBox(height: 20),

            ListTile(
              title: Text(
                birthDate == null
                    ? "생년월일 선택"
                    : "${birthDate!.year}-${birthDate!.month}-${birthDate!.day}",
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: topic,
              items: ["여행", "음식", "취미", "운동"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => topic = v),
              decoration: const InputDecoration(labelText: "관심 주제"),
            ),
            const SizedBox(height: 20),

            ElevatedButton(onPressed: _saveProfile, child: const Text("저장")),
          ],
        ),
      ),
    );
  }
}
