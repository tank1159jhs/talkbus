import 'dart:convert';
import 'package:flutter/material.dart';
import '../api/api_client.dart';
import 'signup.dart';
import 'home.dart';
import 'upsert_profile.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      _showErrorDialog("이메일을 입력해주세요.");
      return;
    }
    if (password.isEmpty) {
      _showErrorDialog("비밀번호를 입력해주세요.");
      return;
    }

    try {
      final res = await ApiClient.post("/auth/login", {
        "email": email,
        "password": password,
      });

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final token = data['token'] as String?;
        final user = data['user'];

        if (token == null) {
          _showErrorDialog("로그인 실패: 서버에서 토큰을 받지 못했습니다.");
          return;
        }

        await ApiClient.saveToken(token);
        await ApiClient.setCurrentUserId(user['id']);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("로그인 성공!")),
        );

        final nickname = user['nickname'] as String?;
        if (nickname == null || nickname.isEmpty) {
          // 프로필 미작성 → 프로필 작성 화면으로 이동
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UpsertProfileScreen()),
          );
        } else {
          // 프로필 작성 완료 → 홈 화면
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        final data = jsonDecode(res.body);
        _showErrorDialog("로그인 실패: ${data['message'] ?? res.body}");
      }
    } catch (e) {
      _showErrorDialog("에러 발생: $e");
    }
  }

/// ✅ 비회원(게스트) 로그인
Future<void> _guestLogin() async {
  try {
    final res = await ApiClient.post("/auth/guest", {});
    debugPrint("🔹 [GuestLogin] Response: ${res.statusCode} ${res.body}");

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);

      // 토큰 안전하게 추출
      final token = data['token'] ?? data['access_token'];
      if (token == null) {
        throw Exception("서버 응답에 토큰이 없습니다: ${res.body}");
      }

      // JWT 저장
      await ApiClient.saveToken(token);
      if (data['user']?['id'] != null) {
        await ApiClient.setCurrentUserId(data['user']['id']);
      }

      // 사용자 정보도 있으면 로그로 확인
      final nickname = data['user']?['nickname'] ?? '(알 수 없음)';
      debugPrint("✅ 게스트 로그인 성공: $nickname");

      if (!mounted) return;
      // 알림 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("게스트 모드로 입장했습니다. ($nickname)")),
      );

      // 홈 화면으로 이동
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      _showErrorDialog("게스트 로그인 실패: ${res.body}");
    }
  } catch (e, stack) {
    debugPrint("❌ 게스트 로그인 에러: $e");
    debugPrint(stack.toString());
    _showErrorDialog("에러 발생: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("로그인")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "E-mail")),
            const SizedBox(height: 10),
            TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text("로그인")),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                );
              },
              child: const Text("회원가입"),
            ),
            const SizedBox(height: 20),
            // ✅ 비회원 로그인 버튼
            OutlinedButton(
              onPressed: _guestLogin,
              child: const Text("비회원으로 진행"),
            ),
          ],
        ),
      ),
    );
  }
}
