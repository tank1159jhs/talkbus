import 'package:flutter/material.dart';
import '../api/api_client.dart';
import 'home.dart';

class PhoneVerifyScreen extends StatefulWidget {
  const PhoneVerifyScreen({super.key});

  @override
  State<PhoneVerifyScreen> createState() => _PhoneVerifyScreenState();
}

class _PhoneVerifyScreenState extends State<PhoneVerifyScreen> {
  final phoneController = TextEditingController();
  final codeController = TextEditingController();
  bool _codeSent = false;

  Future<void> requestCode() async {
    final res = await ApiClient.post("/auth/request-code", {"phone": phoneController.text});
    if (!mounted) return;
    if (res.statusCode == 200) {
      setState(() => _codeSent = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("인증 코드 전송 (콘솔 확인)")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("실패: ${res.body}")));
    }
  }

  Future<void> verifyCode() async {
    final res = await ApiClient.post("/auth/verify-code", {
      "phone": phoneController.text,
      "code": codeController.text,
    });
    if (!mounted) return;
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("휴대폰 인증 완료!")));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("실패: ${res.body}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("휴대폰 인증")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone")),
            if (_codeSent)
              TextField(controller: codeController, decoration: const InputDecoration(labelText: "Code")),
            const SizedBox(height: 20),
            !_codeSent
                ? ElevatedButton(onPressed: requestCode, child: const Text("코드 요청"))
                : ElevatedButton(onPressed: verifyCode, child: const Text("코드 확인")),
          ],
        ),
      ),
    );
  }
}
