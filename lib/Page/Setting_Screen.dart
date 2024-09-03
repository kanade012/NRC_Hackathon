import 'package:delight/Config/Setting_Provider.dart';
import 'package:delight/Config/color.dart';
import 'package:delight/Page/MainPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screen_brightness/screen_brightness.dart'; // 추가
import '../Widget/Custom_Card.dart';
import '../main.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  void initState() {
    super.initState();
    _loadPreferences(); // SharedPreferences에서 값을 불러옵니다.
  }

  // SharedPreferences에서 저장된 값을 불러오는 함수
  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final settingsProvider =
    Provider.of<SettingsProvider>(context, listen: false);
    setState(() {
      settingsProvider.vibrationIntensity =
          prefs.getDouble('vibrationIntensity') ?? 1.0;
      settingsProvider.brightness = prefs.getDouble('brightness') ?? 1.0;
      settingsProvider.textSize = prefs.getDouble('textSize') ?? 26.0;
      settingsProvider.Mode = prefs.getInt('Mode') ?? 0;
    });

    // 화면 밝기를 설정합니다.
    _updateBrightness(settingsProvider.brightness);
  }

  // 화면 밝기를 업데이트하는 함수
  Future<void> _updateBrightness(double brightness) async {
    try {
      // brightness 값을 0.0 ~ 1.0 범위로 조정
      double normalizedBrightness = brightness / 10.0;

      await ScreenBrightness().setScreenBrightness(normalizedBrightness);
    } catch (e) {
      print("Failed to set brightness: $e");
    }
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
    final settingsProvider =
    Provider.of<SettingsProvider>(context, listen: false);
    return PageView(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomUpDownCard(
                title: "모드 전환",
                value: settingsProvider.Mode,
                onChanged: (value) {
                  setState(() {
                    settingsProvider.Mode = value;
                    _updatePreferences('Mode', value);
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
                title: "진동세기",
                value: settingsProvider.vibrationIntensity,
                onChanged: (value) {
                  setState(() {
                    settingsProvider.vibrationIntensity = value;
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
                value: settingsProvider.brightness,
                onChanged: (value) {
                  setState(() {
                    settingsProvider.brightness = value;
                    _updatePreferences('brightness', value);
                    _updateBrightness(value); // 밝기 업데이트
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
                  value: settingsProvider.textSize,
                  onChanged: (value) {
                    setState(() {
                      settingsProvider.textSize = value;
                      _updatePreferences('textSize', value);
                    });
                  },
                ),
              ],
            )),
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
      ],
    );
  }
}
