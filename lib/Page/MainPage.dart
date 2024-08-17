import 'package:delight/Widget/Custom_Card.dart';
import 'package:flutter/material.dart';
import 'package:delight/Config/color.dart';
import 'package:vibration/vibration.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        Scaffold(
          backgroundColor: DelightColors.background,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Delight",
                  style: TextStyle(
                      color: DelightColors.darkgrey,
                      fontSize: 40, // 폰트 사이즈 Wear OS에 맞게 조정
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications_none,
                        color: DelightColors.darkgrey,
                        size: 40,
                      ),
                      onPressed: () async {
                        if (await Vibration.hasVibrator() ?? false) {
                          Vibration.vibrate(duration: 500); // 500ms 동안 진동
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("진동 시작됨")),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("진동 기능이 없습니다")),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.settings,
                        color: DelightColors.darkgrey,
                        size: 40,
                      ),
                      onPressed: () {},
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomSliderCard(title: "진동세기", value: 1),
            ],
          ),
        ),
        Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomSliderCard(title: "밝기", value: 1),
            ],
          ),
        ),
        Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomUpDownCard(title: "전환 시간", value: 1),
            ],
          ),
        ),
        Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomUpDown2Card(title: "텍스트 크기", value: 40.0),
            ],
          ),
        ),
      ],
    );
  }
}
