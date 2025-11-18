import 'dart:convert';
import 'dart:io' show Platform, File;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class ApiClient {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:3000"; // Android 에뮬레이터
    } else if (Platform.isIOS) {
      return "http://127.0.0.1:3000"; // iOS 시뮬레이터
    } else {
      return "http://localhost:3000"; // 데스크탑 실행용
    }
  }

  static String get wsUrl {
    if (Platform.isAndroid) {
      return "ws://10.0.2.2:3000"; // Android 에뮬레이터 WebSocket
    } else if (Platform.isIOS) {
      return "ws://127.0.0.1:3000"; // iOS 시뮬레이터 WebSocket
    } else {
      return "ws://localhost:3000"; // 데스크탑 WebSocket
    }
  }

  static String? currentUserId;

  static Future<void> setCurrentUserId(String userId) async {
    currentUserId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_id', userId);
  }

  static Future<String?> getCurrentUserId() async {
    if (currentUserId != null) return currentUserId;
    final prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString('current_user_id');
    return currentUserId;
  }

  // JWT 토큰 저장
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // JWT 토큰 가져오기
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // 공통 GET
  static Future<http.Response> get(String path) async {
    final token = await getToken();
    return http.get(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  // 공통 POST
  static Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final token = await getToken();
    return http.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  // 공통 PUT
  static Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final token = await getToken();
    return http.put(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  // 공통 DELETE
  static Future<http.Response> delete(String path) async {
    final token = await getToken();
    return http.delete(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  // ✅ 로그아웃 추가
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // DirectRoom 목록 가져오기
  static Future<List<DirectRoom>> fetchDirectRooms() async {
    final res = await get('/direct-rooms');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => DirectRoom.fromJson(e)).toList();
    }
    throw Exception('Failed to load direct rooms');
  }

  // DirectRoom 생성
  static Future<DirectRoom> createDirectRoom({required String userAId, required String userBId}) async {
    final res = await post('/direct-rooms', {
      'userAId': userAId,
      'userBId': userBId,
    });
    if (res.statusCode == 201) {
      return DirectRoom.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to create direct room');
  }

  // DirectMessage 목록 가져오기
  static Future<List<DirectMessage>> fetchDirectMessages(String roomId) async {
    final res = await get('/talks/$roomId/chats');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => DirectMessage.fromJson(e)).toList();
    }
    throw Exception('Failed to load direct messages: ${res.statusCode} ${res.body}');
  }

  // DirectMessage 전송
  static Future<void> sendDirectMessage(String roomId, String body) async {
    debugPrint('[API] Sending message to /talks/$roomId/chats with body: $body');
    final res = await post('/talks/$roomId/chats', {
      'body': body,
    });
    debugPrint('[API] Response status: ${res.statusCode}');
    if (res.statusCode != 201) {
      throw Exception('Failed to send direct message: ${res.statusCode} ${res.body}');
    }
  }

  // GroupRoom 목록 가져오기
  static Future<List<GroupRoom>> fetchGroupRooms() async {
    final res = await get('/groups');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => GroupRoom.fromJson(e)).toList();
    }
    throw Exception('Failed to load group rooms');
  }

  // GroupRoom 생성
  static Future<GroupRoom> createGroupRoom({required String title}) async {
    final res = await post('/groups', {
      'title': title,
    });
    if (res.statusCode == 201) {
      return GroupRoom.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to create group room');
  }

  // GroupMessage 목록 가져오기
  static Future<List<GroupMessage>> fetchGroupMessages(String roomId) async {
    final res = await get('/groups/$roomId/messages');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => GroupMessage.fromJson(e)).toList();
    }
    throw Exception('Failed to load group messages: ${res.statusCode} ${res.body}');
  }

  // GroupMessage 전송
  static Future<void> sendGroupMessage(String roomId, String body) async {
    debugPrint('[API] Sending group message to /groups/$roomId/messages with body: $body');
    final res = await post('/groups/$roomId/messages', {
      'body': body,
    });
    debugPrint('[API] Response status: ${res.statusCode}');
    if (res.statusCode != 201) {
      throw Exception('Failed to send group message: ${res.statusCode} ${res.body}');
    }
  }

  // Group 참가
  static Future<void> joinGroup(String groupId) async {
    debugPrint('[API] Joining group: $groupId');
    final res = await post('/groups/$groupId/join', {});
    debugPrint('[API] Join response status: ${res.statusCode}');
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Failed to join group: ${res.statusCode} ${res.body}');
    }
  }

  // 프로필 이미지 업로드
  static Future<bool> uploadProfileImage(File imageFile) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/users/profile-image');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = token != null ? 'Bearer $token' : ''
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    final response = await request.send();
    return response.statusCode == 200;
  }

  // 비밀사진 업로드
  static Future<bool> uploadSecretImage(File imageFile) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/users/secret-image');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = token != null ? 'Bearer $token' : ''
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    final response = await request.send();
    return response.statusCode == 200;
  }

  // 닉네임 변경
  static Future<bool> updateNickname(String nickname) async {
    final res = await put('/users/profile', { 'nickname': nickname });
    return res.statusCode == 200;
  }

  // UserProfile 모델
  static Future<UserProfile> fetchProfile({String? userId}) async {
    final res = userId == null
      ? await get('/users/me') // 로그인한 사용자 정보는 /users/me로 요청
      : await get('/users/$userId'); // 특정 사용자 정보는 /users/:id로 요청
    if (res.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to fetch profile');
  }

  // 토크 게시글 리스트 가져오기
  static Future<List<TalkPost>> fetchTalkPosts() async {
    final res = await get('/talkposts');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => TalkPost.fromJson(e)).toList();
    }
    throw Exception('Failed to load talk posts');
  }

  // 토크 게시글 등록
  static Future<TalkPost> createTalkPost({required String title, required String content}) async {
    final userId = await getCurrentUserId();
    final res = await post('/talkposts', {
      'authorId': userId,
      'title': title,
      'content': content,
    });
    if (res.statusCode == 201 || res.statusCode == 200) {
      return TalkPost.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to create talk post');
  }

  // 토크 게시글 삭제
  static Future<void> deleteTalkPost(String postId) async {
    final res = await delete('/talkposts/$postId');
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to delete talk post');
    }
  }
}
