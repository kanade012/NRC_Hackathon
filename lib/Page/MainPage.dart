import 'package:delight/Widget/Custom_Card.dart';
import 'package:flutter/material.dart';

import '../Config/color.dart';
import '../main.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: DelightColors.background,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(ratio.width * 15),
            child: Column(
                children: [
              //CustomAppBar
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Delight",
                      style: TextStyle(
                          color: DelightColors.darkgrey,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                  Spacer(),
                  GestureDetector(
                      onTap: () {},
                      child: Icon(
                        Icons.notifications_none,
                        color: DelightColors.darkgrey,
                        size: 26,
                      )),
                  SizedBox(width: 15),
                  GestureDetector(
                      onTap: () {},
                      child:
                          Icon(Icons.settings, color: DelightColors.darkgrey)),
                ],
              ),
              //Header
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("연결 상태 :",
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        SizedBox(
                          width: ratio.width * 10,
                        ),
                        Text("200 OK",
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: DelightColors.mainBlue)),
                      ],
                    ),
                  ),
                ),
              ),
              //body
              SizedBox(height: 50),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text("설정 관리",
                    style: TextStyle(
                        fontSize: 27,
                        color: DelightColors.darkgrey,
                        fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: ratio.height * 20,
              ),
              Container(
                width: double.infinity,
                height: ratio.height * 490,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CustomSliderCard(title: "진동", value: 1),
                      CustomSliderCard(title: "밝기", value: 1),
                      CustomUpDownCard(title: "전환 시간", value: 1),
                      CustomUpDown2Card(title: "텍스트 크기", value: 1.0),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ));
  }
}
