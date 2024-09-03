import 'package:delight/Config/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delight/Config/Setting_Provider.dart';
import '../main.dart';


class CustomSliderCard extends StatefulWidget {
  final String title;
  final double value;
  final ValueChanged<double> onChanged; // 콜백 추가

  CustomSliderCard({
    required this.title,
    required this.value,
    required this.onChanged, // 콜백 초기화
    super.key,
  });

  @override
  State<CustomSliderCard> createState() => _CustomSliderCardState();
}

class _CustomSliderCardState extends State<CustomSliderCard> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // 추가된 코드
        children: [
          Text(widget.title,
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: DelightColors.mainBlue)),
          SliderPage(
            value1: _currentValue,
            onChanged: (value) {
              setState(() {
                _currentValue = value;
              });
              widget.onChanged(value); // 부모 위젯에 값 전달
            },
          ),
          Text("${_currentValue.toStringAsFixed(2)}"), // 소수점 두 자리로 표시
        ],
      ),
    );
  }
}
class SliderPage extends StatefulWidget {
  double value1;
  final ValueChanged<double> onChanged;

  SliderPage({super.key, required this.value1, required this.onChanged});

  @override
  State<SliderPage> createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  @override
  Widget build(BuildContext context) {
    return Slider(
      activeColor: DelightColors.mainBlue,
      inactiveColor: DelightColors.subBlue,
      value: widget.value1,
      min: 1,
      max: 10,
      label: widget.value1.round().toString(),
      divisions: 9,
      onChanged: (value) {
        setState(() {
          widget.value1 = value;
        });
        widget.onChanged(value);
      },
    );
  }
}

class CustomUpDownCard extends StatefulWidget {
  final String title;
  final int value;
  final ValueChanged<int> onChanged;

  CustomUpDownCard({
    required this.title,
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  State<CustomUpDownCard> createState() => _CustomUpDownCardState();
}

class _CustomUpDownCardState extends State<CustomUpDownCard> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  // A method to map _currentValue to the corresponding text
  String getModeText(int value) {
    switch (value) {
      case 0:
        return '일반';
      case 1:
        return '운전';
      case 2:
        return '수면';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    return Container(
      margin: EdgeInsets.all(ratio.width * 10),
      padding: EdgeInsets.all(ratio.width * 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(widget.title,
              style: TextStyle(
                  fontSize: settingsProvider.textSize,
                  fontWeight: FontWeight.bold,
                  color: DelightColors.mainBlue)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_currentValue > 0) _currentValue -= 1;
                  });
                  widget.onChanged(_currentValue);
                },
                child: Icon(
                  CupertinoIcons.arrowtriangle_left_fill,
                  color: DelightColors.mainBlue,
                  size: 40,
                ),
              ),
              // Display text based on _currentValue
              Text(getModeText(_currentValue),
                  style: TextStyle(
                    fontSize: 40,
                    color: DelightColors.mainBlue,
                  )),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_currentValue < 2) _currentValue += 1;
                  });
                  widget.onChanged(_currentValue);
                },
                child: Icon(
                  CupertinoIcons.arrowtriangle_right_fill,
                  color: DelightColors.mainBlue,
                  size: 40,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}


class CustomUpDown2Card extends StatefulWidget {
  final String title;
  final double value;
  final ValueChanged<double> onChanged; // 콜백 추가

  CustomUpDown2Card({
    required this.title,
    required this.value,
    required this.onChanged, // 콜백 초기화
    super.key,
  });

  @override
  State<CustomUpDown2Card> createState() => _CustomUpDownCard2State();
}

class _CustomUpDownCard2State extends State<CustomUpDown2Card> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value; // 초기값 설정
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider =
    Provider.of<SettingsProvider>(context, listen: false);
    return Container(
      margin: EdgeInsets.all(ratio.width * 10),
      padding: EdgeInsets.all(ratio.width * 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(widget.title,
              style: TextStyle(
                  fontSize: settingsProvider.textSize,
                  fontWeight: FontWeight.bold,
                  color: DelightColors.mainBlue)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentValue -= 1.0;
                  });
                  widget.onChanged(_currentValue); // 부모 위젯에 값 전달
                },
                child: Icon(
                  CupertinoIcons.arrowtriangle_left_fill,
                  color: DelightColors.mainBlue,
                  size: 40,
                ),
              ),
              Text('가', // 업데이트된 값을 표시
                  style: TextStyle(
                    fontSize: _currentValue, // 디자인에 맞게 폰트 크기 조정
                    color: DelightColors.mainBlue,
                  )),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentValue += 1.0;
                  });
                  widget.onChanged(_currentValue); // 부모 위젯에 값 전달
                },
                child: Icon(
                  CupertinoIcons.arrowtriangle_right_fill,
                  color: DelightColors.mainBlue,
                  size: 40,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
