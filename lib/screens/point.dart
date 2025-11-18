import 'package:flutter/material.dart';

class PointScreen extends StatelessWidget {
  const PointScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> chargeOptions = [
      {'points': 1000, 'price': 150, 'bonus': 0},
      {'points': 3000, 'price': 500, 'bonus': 10},
      {'points': 5000, 'price': 800, 'bonus': 15},
      {'points': 10000, 'price': 1500, 'bonus': 20},
      {'points': 30000, 'price': 5000, 'bonus': 25},
      {'points': 50000, 'price': 8000, 'bonus': 30},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('포인트', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.grey.shade100,
            child: const Text(
              '내 포인트 : 345',
              style: TextStyle(fontSize: 20, color: Colors.red),
            ),
          ),
          const SizedBox(height: 8),
          const Text('포인트 충전 - 부가세(VAT) 포함',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: chargeOptions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final option = chargeOptions[i];
                return ListTile(
                  title: Row(
                    children: [
                      Text('${option['points']} 포인트'),
                      if (option['bonus'] > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(
                            '+${option['bonus']}%',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                  trailing: Text('¥${option['price']}'),
                  onTap: () {
                    // TODO: 실제 결제 로직 연결
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${option['points']} 포인트 충전 선택됨')),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('포인트 충전 내역'),
            subtitle: const Text('미지급된 포인트를 조회합니다.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            title: const Text('포인트 복구'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
