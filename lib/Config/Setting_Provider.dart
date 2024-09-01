import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  double _vibrationIntensity = 1.0;
  double _brightness = 1.0;
  double _textSize = 26.0;
  int _Mode = 0;

  double get vibrationIntensity => _vibrationIntensity;
  set vibrationIntensity(double value) {
    _vibrationIntensity = value;
    notifyListeners();
  }

  double get brightness => _brightness;
  set brightness(double value) {
    _brightness = value;
    notifyListeners();
  }

  double get textSize => _textSize;
  set textSize(double value) {
    _textSize = value;
    notifyListeners();
  }

  int get Mode => _Mode;
  set Mode(int value) {
    _Mode = value;
    notifyListeners();
  }

  // SharedPreferences에서 저장된 값을 불러오는 함수
  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    vibrationIntensity = prefs.getDouble('vibrationIntensity') ?? 1.0;
    brightness = prefs.getDouble('brightness') ?? 1.0;
    textSize = prefs.getDouble('textSize') ?? 26.0;
    Mode = prefs.getInt('Mode') ?? 1;
  }

  // SharedPreferences에 값을 저장하는 함수
  Future<void> updatePreferences(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
  }
}
