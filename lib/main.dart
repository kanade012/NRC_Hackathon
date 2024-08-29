import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    initializeNotifications();
  }

  void initializeNotifications() async {
    // Android 13 이상에서는 알림 권한이 필요합니다.
    await requestNotificationPermission();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // onSelectNotification을 대체하는 코드
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // 알림을 클릭했을 때 처리할 동작을 정의합니다.
        String? payload = response.payload;
        print('알림 선택됨: $payload');
        // 알림 클릭 시 원하는 작업을 여기에 추가
      },
    );
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.request().isGranted) {
      print('알림 권한이 허용되었습니다.');
    } else {
      print('알림 권한이 거부되었습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Manual Push Notification'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: _showNotification,
            child: Text('Send Notification'),
          ),
        ),
      ),
    );
  }

  Future<void> _showNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );

    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Manual Notification',
      'This is a manually triggered notification',
      platformChannelSpecifics,
      payload: 'Custom Payload',
    );
  }
}



// import 'package:flutter/material.dart';
// import 'Config/bluetooth_provider.dart';
// import 'Page/MainPage.dart';
// import 'package:provider/provider.dart';
//
// late Size ratio;
//
// void main() {
//   runApp(
//     ChangeNotifierProvider(
//       create: (context) => BluetoothManager(),
//       child: MyApp(),
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     ratio = Size(MediaQuery.sizeOf(context).width / 412,
//         MediaQuery.sizeOf(context).height / 892);
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: MainPage(),
//     );
//   }
// }