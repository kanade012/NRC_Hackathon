import 'package:flutter/material.dart';
import 'package:delight/Config/color.dart';

import 'Alarm_Screen.dart';
import 'Setting_Screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return
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
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Alarm()));
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.settings,
                        color: DelightColors.darkgrey,
                        size: 40,
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Setting()));
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        );
  }
}
