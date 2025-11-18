import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:talkbus/api/api_client.dart';
import 'package:talkbus/l10n/app_localizations.dart';

class MyProfileScreen extends StatefulWidget {
  final String? userId;
  const MyProfileScreen({super.key, this.userId});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  File? _profileImage;
  File? _secretImage;
  String? _profileImageUrl;
  String? _secretImageUrl;
  // 프로필 정보 변수: 초기값 없이 선언만
  String _nickname = '';
  String _email = '';
  String _gender = '';
  String _age = '';
  String _theme = '';
  bool _loading = false;

  // 일본어 현지화(i18n) 적용 예시
  String get _profileEditTitle => AppLocalizations.of(context)!.profile_edit;
  String get _nicknameEditTitle => AppLocalizations.of(context)!.nickname_edit;
  String get _nicknameEditHint => AppLocalizations.of(context)!.nickname_edit_hint;
  String get _profilePhotoLabel => AppLocalizations.of(context)!.profile_photo;
  String get _secretPhotoLabel => AppLocalizations.of(context)!.secret_photo;
  String get _uploadSuccess => AppLocalizations.of(context)!.upload_success;
  String get _uploadFail => AppLocalizations.of(context)!.upload_fail;
  String get _nicknameChanged => AppLocalizations.of(context)!.nickname_changed;
  String get _nicknameChangeFail => AppLocalizations.of(context)!.nickname_change_fail;

  @override
  void initState() {
    super.initState();
    _initUserIdAndFetchProfile();
  }

  Future<void> _initUserIdAndFetchProfile() async {
    String? userId = widget.userId;
    if (userId == null) {
      userId = await ApiClient.getCurrentUserId();
    }
    setState(() { _loading = true; });
    try {
      final profile = await ApiClient.fetchProfile(userId: userId);
      setState(() {
        _nickname = profile.nickname;
        _profileImageUrl = profile.profileImageUrl;
        _secretImageUrl = profile.secretImageUrl;
        _email = profile.email ?? '';
        // 추가: gender, age, theme
        _gender = profile.gender ?? '';
        _age = profile.age?.toString() ?? '';
        _theme = profile.theme ?? '';
      });
    } catch (e) {
      debugPrint('프로필 불러오기 실패: $e');
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _pickProfilePhoto(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() { _profileImage = File(picked.path); });
      final success = await ApiClient.uploadProfileImage(_profileImage!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? _uploadSuccess : _uploadFail)),
      );
    }
  }

  Future<void> _pickSecretPhoto(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() { _secretImage = File(picked.path); });
      final success = await ApiClient.uploadSecretImage(_secretImage!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? _uploadSuccess : _uploadFail)),
      );
    }
  }

  Future<void> _editNickname(BuildContext context) async {
    final controller = TextEditingController(text: _nickname);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_nicknameEditTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: _nicknameEditHint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ApiClient.updateNickname(controller.text);
              if (success) {
                setState(() { _nickname = controller.text; });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_nicknameChanged)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_nicknameChangeFail)),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        title: Text(_profileEditTitle, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.redAccent.withAlpha(13),
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty
                              ? NetworkImage(_profileImageUrl!)
                              : null) as ImageProvider?,
                      child: (_profileImage == null && (_profileImageUrl == null || _profileImageUrl!.isEmpty))
                          ? const Icon(Icons.person, size: 48, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_nickname, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                          tooltip: 'ニックネーム/写真変更',
                          onPressed: () => _openEditSheet(context),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 기본 정보 섹션 (샘플)
                _kv('E-mail', _email),
                _kv('Gender', _gender, valueStyle: const TextStyle(color: Colors.blue)),
                _kv('Age', _age),
                _kv('Theme', _theme),
                const SizedBox(height: 16),

                // 사진들
                Text(_profilePhotoLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _photoBox(
                  onTap: (ctx) => _pickProfilePhoto(ctx),
                  image: _profileImage,
                  imageUrl: _profileImageUrl,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Text(_secretPhotoLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    const Icon(Icons.help_outline, size: 16, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 8),
                _photoBox(
                  onTap: (ctx) => _pickSecretPhoto(ctx),
                  image: _secretImage,
                  imageUrl: _secretImageUrl,
                ),

                const SizedBox(height: 24),
                const Text('Message', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                const Text('Introduce', style: TextStyle(color: Colors.grey)),
              ],
            ),
    );
  }

  // Key-Value 행
  static Widget _kv(String k, String v, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(k, style: const TextStyle(color: Colors.grey))),
          const SizedBox(width: 8),
          Expanded(child: Text(v, style: valueStyle)),
        ],
      ),
    );
  }

  Widget _photoBox({required void Function(BuildContext) onTap, File? image, String? imageUrl}) {
    return AspectRatio(
      aspectRatio: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => onTap(context),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.lightBlue, width: 2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.file(image, fit: BoxFit.cover),
                )
              : (imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(imageUrl, fit: BoxFit.cover),
                    )
                  : const Center(
                      child: Icon(Icons.add, size: 36, color: Colors.lightBlue),
                    )),
        ),
      ),
    );
  }

  void _openEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('프로필 사진 변경'),
              onTap: () { Navigator.pop(context); _pickProfilePhoto(context); },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('비밀사진 변경'),
              onTap: () { Navigator.pop(context); _pickSecretPhoto(context); },
            ),
            const Divider(height: 0),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('닉네임 수정'),
              onTap: () { Navigator.pop(context); _editNickname(context); },
            ),
          ],
        ),
      ),
    );
  }
}