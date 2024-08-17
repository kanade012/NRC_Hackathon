import 'package:delight/Config/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import 'Custom_Slider.dart';

class CustomSliderCard extends StatefulWidget {
  final String title;
  final double value;

  CustomSliderCard({
    required this.title,
    required this.value,
    super.key,
  });

  @override
  State<CustomSliderCard> createState() => _CustomSliderCardState();
}

class _CustomSliderCardState extends State<CustomSliderCard> {
  late double _currentValue = 1.0;

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
            },
          ),
          Text("${_currentValue.toStringAsFixed(2)}"), // 소수점 두 자리로 표시
        ],
      ),
    );
  }
}

class CustomUpDownCard extends StatefulWidget {
  final String title;
  final int value;

  CustomUpDownCard({
    required this.title,
    required this.value,
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
    _currentValue = widget.value; // 초기값 설정
  }

  @override
  Widget build(BuildContext context) {
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
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: DelightColors.mainBlue)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentValue -= 1;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 3, color: DelightColors.mainBlue)),
                  child: Icon(
                    CupertinoIcons.minus,
                    color: DelightColors.mainBlue,
                    size: 40,
                  ),
                ),
              ),
              Text('$_currentValue', // 업데이트된 값을 표시
                  style: TextStyle(
                    fontSize: 40, // 디자인에 맞게 폰트 크기 조정
                    color: DelightColors.mainBlue,
                  )),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentValue += 1;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 3, color: DelightColors.mainBlue)),
                  child: Icon(
                    CupertinoIcons.plus,
                    color: DelightColors.mainBlue,
                    size: 40,
                  ),
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

  CustomUpDown2Card({
    required this.title,
    required this.value,
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
                  fontSize: 26,
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
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 3, color: DelightColors.mainBlue)),
                  child: Icon(
                    CupertinoIcons.minus,
                    color: DelightColors.mainBlue,
                    size: 40,
                  ),
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
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 3, color: DelightColors.mainBlue)),
                  child: Icon(
                    CupertinoIcons.plus,
                    color: DelightColors.mainBlue,
                    size: 40,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
