import 'package:flutter/material.dart';

class TermsDialog extends StatelessWidget {
  const TermsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단 헤더
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Text(
              "이용약관",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          // 본문
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: const Text(
                "이용약관\n\n제1장 총칙\n제1조 (목적)\n...\n\n"
                "위치기반 서비스 이용약관\n...\n\n"
                "개인정보 취급방침\n...",
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
          ),

          const Divider(height: 1),

          // 버튼 영역
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false), // ❌ 동의 안함
                  child: const Text("동의 안함"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, true), // ✅ 동의
                  child: const Text("동의"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
