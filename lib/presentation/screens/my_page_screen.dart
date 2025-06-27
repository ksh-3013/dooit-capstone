import 'package:flutter/material.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const basePadding = EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F3EF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: basePadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/mydooit.png',
                    height: 32,
                  ),
                  Row(
                    children: const [
                      Icon(Icons.settings, color: Colors.black),
                      SizedBox(width: 12),
                      Icon(Icons.notifications_none, color: Colors.black),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                //아바타
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Lv.1"),
                    Text("필기왕돼지73"),

                  ],
                )
              ],
            ),

            const SizedBox(height: 16),
            Padding(
              padding: basePadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _MenuIcon(icon: Icons.confirmation_number, label: "내 이용권"),
                  _MenuIcon(icon: Icons.check_circle, label: "체크인"),
                  _MenuIcon(icon: Icons.school, label: "우리 학교"),
                  _MenuIcon(icon: Icons.local_offer, label: "쿠폰"),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Padding(
              padding: basePadding,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: const Text(
                  "공부 타이머 집에서도 가능!",
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Padding(
              padding: basePadding,
              child: _Section(title: "나의 활동", items: [
                "내가 쓴 리뷰",
                "밀리토크 활동",
                "결제 내역",
                "관심 밀리존",
              ]),
            ),

            Padding(
              padding: basePadding,
              child: _Section(title: "보호자", items: [
                "보호자 연동",
                "맘 찬스 내역",
              ]),
            ),

            Padding(
              padding: basePadding,
              child: _Section(title: "밀리언즈 소식", items: [
                "이벤트",
                "밀리언즈 가이드",
                "공지사항",
              ]),
            ),

            Padding(
              padding: basePadding,
              child: _Section(title: "도움말", items: [
                "고객센터",
              ]),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _MenuIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MenuIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 36, color: Colors.deepPurple),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<String> items;

  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
              (item) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              item,
              style: const TextStyle(fontFamily: 'Pretendard'),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
