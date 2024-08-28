import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delight/Config/Setting_Provider.dart';
import 'Page/MainPage.dart';

late Size ratio;

void main() {
  runApp(ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ratio = Size(MediaQuery.sizeOf(context).width / 412,
        MediaQuery.sizeOf(context).height / 892);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}
