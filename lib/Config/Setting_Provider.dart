import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  double _vibrationIntensity = 1.0;
  int _Alarm = 0;
  int _Mode = 0;

  double get vibrationIntensity => _vibrationIntensity;
  set vibrationIntensity(double value) {
    _vibrationIntensity = value;
    updatePreferences('vibrationIntensity', value);
    notifyListeners();
  }

  int get Alarm => _Alarm;
  set Alarm(int value) {
    _Alarm = value;
    updatePreferences('Alarm', value);
    notifyListeners();
  }

  int get Mode => _Mode;
  set Mode(int value) {
    _Mode = value;
    updatePreferences('Mode', value);
    notifyListeners();
  }

  SettingsProvider() {
    loadPreferences();
  }

  // SharedPreferences에서 저장된 값을 불러오는 함수
  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _vibrationIntensity = prefs.getDouble('vibrationIntensity') ?? 1.0;
    _Alarm = prefs.getInt('Alarm') ?? 0;
    _Mode = prefs.getInt('Mode') ?? 0;
    notifyListeners();
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