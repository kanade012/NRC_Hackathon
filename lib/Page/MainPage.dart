import 'package:flutter/material.dart';
import 'package:delight/Config/color.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Config/Setting_Provider.dart';
import 'Alarm_Screen.dart';
import 'Setting_Screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
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
      settingsProvider.transitionTime = prefs.getInt('transitionTime') ?? 1;
    });
  }
  @override
  Widget build(BuildContext context) {
    final settingsProvider =
    Provider.of<SettingsProvider>(context, listen: false);
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
                      fontSize: settingsProvider.textSize, // 폰트 사이즈 Wear OS에 맞게 조정
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
