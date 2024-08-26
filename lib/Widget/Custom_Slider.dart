import 'package:delight/Config/color.dart';
import 'package:flutter/material.dart';

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
      max: 10,
      label: widget.value1.round().toString(),
      divisions: 10,
      onChanged: (value) {
        setState(() {
          widget.value1 = value;
        });
        widget.onChanged(value);
      },
    );
  }
}
