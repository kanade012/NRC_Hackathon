import 'package:delight/Config/color.dart';
import 'package:delight/Page/MainPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Widget/Custom_Card.dart';
import '../main.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  double vibrationIntensity = 1.0;  // 진동 세기
  double brightness = 1.0;          // 밝기
  double textSize = 40.0;            // 텍스트 크기
  int transitionTime = 1;            // 전환 시간

  @override
  void initState() {
    super.initState();
    _loadPreferences();  // SharedPreferences에서 값을 불러옵니다.
  }

  // SharedPreferences에서 저장된 값을 불러오는 함수
  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      vibrationIntensity = prefs.getDouble('vibrationIntensity') ?? 1.0;
      brightness = prefs.getDouble('brightness') ?? 1.0;
      textSize = prefs.getDouble('textSize') ?? 40.0;
      transitionTime = prefs.getInt('transitionTime') ?? 1;
    });
  }

  // SharedPreferences에 값을 저장하는 함수
  Future<void> _updatePreferences(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => MainPage()));
          },
          child: Scaffold(
            backgroundColor: DelightColors.background,
            body: Container(
              child: Center(
                  child: Icon(
                    Icons.arrow_back,
                    size: ratio.width * 200,
                    color: DelightColors.grey1,
                  )),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomSliderCard(
                title: "진동세기",
                value: vibrationIntensity,
                onChanged: (value) {
                  setState(() {
                    vibrationIntensity = value;
                    _updatePreferences('vibrationIntensity', value);
                  });
                },
              ),
            ],
          ),
        ),
        Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomSliderCard(
                title: "밝기",
                value: brightness,
                onChanged: (value) {
                  setState(() {
                    brightness = value;
                    _updatePreferences('brightness', value);
                  });
                },
              ),
            ],
          ),
        ),
        Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomUpDownCard(
                title: "전환 시간",
                value: transitionTime,
                onChanged: (value) {
                  setState(() {
                    transitionTime = value;
                    _updatePreferences('transitionTime', value);
                  });
                },
              ),
            ],
          ),
        ),
        Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomUpDown2Card(
                title: "텍스트 크기",
                value: textSize,
                onChanged: (value) {
                  setState(() {
                    textSize = value;
                    _updatePreferences('textSize', value);
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
