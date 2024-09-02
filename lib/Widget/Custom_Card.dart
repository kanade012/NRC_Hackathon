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
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.title,
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: DelightColors.mainBlue)),
          SliderPage(
            value1: settingsProvider.vibrationIntensity,
            onChanged: (value) {
              widget.onChanged(value);
            },
          ),
          Text("${settingsProvider.vibrationIntensity.toStringAsFixed(2)}"),
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
    final settingsProvider = Provider.of<SettingsProvider>(context);
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
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: DelightColors.mainBlue)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  if (settingsProvider.Mode > 0) {
                    widget.onChanged(settingsProvider.Mode - 1);
                  }
                },
                child: Icon(
                  CupertinoIcons.arrowtriangle_left_fill,
                  color: DelightColors.mainBlue,
                  size: 40,
                ),
              ),
              Text(getModeText(settingsProvider.Mode),
                  style: TextStyle(
                    fontSize: 40,
                    color: DelightColors.mainBlue,
                  )),
              GestureDetector(
                onTap: () {
                  if (settingsProvider.Mode < 2) {
                    widget.onChanged(settingsProvider.Mode + 1);
                  }
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
  final int value;
  final ValueChanged<int> onChanged; // 콜백 추가

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
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
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
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: DelightColors.mainBlue)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  int newValue = settingsProvider.Alarm == 0 ? 1 : 0;
                  widget.onChanged(newValue);
                },
                child: Icon(
                  CupertinoIcons.arrowtriangle_left_fill,
                  color: DelightColors.mainBlue,
                  size: 40,
                ),
              ),
              Text(settingsProvider.Alarm == 0 ? "끔" : "켬",
                  style: TextStyle(
                    fontSize: 32,
                    color: DelightColors.mainBlue,
                  )),
              GestureDetector(
                onTap: () {
                  int newValue = settingsProvider.Alarm == 0 ? 1 : 0;
                  widget.onChanged(newValue);
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

