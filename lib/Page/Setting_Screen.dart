import 'package:delight/Config/color.dart';
import 'package:delight/Page/MainPage.dart';
import 'package:flutter/material.dart';
import '../Widget/Custom_Card.dart';
import '../main.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        GestureDetector(
          onTap: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MainPage()));
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
              CustomSliderCard(title: "진동세기", value: 1),
            ],
          ),
        ),
        Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomSliderCard(title: "밝기", value: 1),
            ],
          ),
        ),
        Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomUpDownCard(title: "전환 시간", value: 1),
            ],
          ),
        ),
        Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomUpDown2Card(title: "텍스트 크기", value: 40.0),
            ],
          ),
        ),
      ],
    );
  }
}
