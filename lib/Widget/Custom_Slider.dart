import 'package:delight/Config/color.dart';
import 'package:flutter/material.dart';

class SliderPage extends StatefulWidget {
  double value1;

  SliderPage({super.key,
  required this.value1});

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
          onChanged: (value) => setState(() {
            widget.value1 = value;
          }));
  }
}