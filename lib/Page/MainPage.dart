import 'package:flutter/material.dart';
import 'package:delight/Config/color.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Config/Setting_Provider.dart';
import '../main.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';
import '../Widget/Custom_Card.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String _detectionResult = "잡음";
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  late Interpreter _interpreter;
  late TensorBuffer _inputBuffer;
  late TensorBuffer _outputBuffer;
  List<int> _pcmDataBuffer = [];
  bool _isRecording = false;
  Timer? _timer;
  StreamController<Food> _streamController = StreamController<Food>();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeInterpreter();
    _requestPermission();
    _initializeNotifications();
    _loadPreferences();
  }

  Future<void> _requestPermission() async {
    await Permission.microphone.request();
    await Permission.notification.request();
    _startContinuousRecording();
  }

  void _initializeNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/logo');

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      '소리 감지', // 채널 ID
      '소리 감지 알림', // 채널 이름
      description: '소리를 감지하여 알림을 표시합니다.', // 채널 설명
      importance: Importance.max,
    );

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    if (notificationResponse.payload != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    }
  }

  Future<void> _showNotification(String result) async {
    // 앱이 foreground 상태인지 확인
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      print("App is in the foreground, notification will not be shown.");
      return;
    }

    print("Showing notification: $result");

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      '소리 감지', // 채널 ID
      'Sound analyze', // 채널 이름
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      fullScreenIntent: true, // 전체 화면 인텐트를 사용하도록 설정
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      '소리 감지', // 제목
      result, // 내용
      platformChannelSpecifics,
      payload: 'MainPage', // 알림을 눌렀을 때 전달할 페이로드
    );
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final settingsProvider =
    Provider.of<SettingsProvider>(context, listen: false);
    setState(() {
      settingsProvider.vibrationIntensity =
          prefs.getDouble('vibrationIntensity') ?? 1.0;
      settingsProvider.Alarm = prefs.getInt('Alarm') ?? 0;
      settingsProvider.Mode = prefs.getInt('Mode') ?? 0;
    });
  }

  Future<void> _initializeInterpreter() async {
    try {
      _interpreter = await Interpreter.fromAsset('model.tflite');
      _inputBuffer =
          TensorBuffer.createFixedSize([1, 15600], TfLiteType.float32);
      _outputBuffer =
          TensorBuffer.createFixedSize([1, 521], TfLiteType.float32);
    } catch (e) {
      print("Error initializing interpreter: $e");
    }
  }

  void _processAudioData(Uint8List pcmData) {
    Float32List floatBuffer = _convertToFloat32(pcmData);

    if (floatBuffer.length != 15600) {
      floatBuffer = _adjustToInputShape(floatBuffer, 15600);
    }

    _inputBuffer.loadList(floatBuffer, shape: [1, 15600]);
    _interpreter.run(_inputBuffer.buffer, _outputBuffer.buffer);

    List<double> outputData = _outputBuffer.getDoubleList();
    print("Model output: $outputData");

    _handleModelOutput(outputData);
  }

  bool _isVibrating = false;

  void _handleModelOutput(List<double> outputData) async {
    if (_isVibrating) return;

    int maxIndex = outputData.indexOf(outputData.reduce((a, b) => a > b ? a : b));
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    print("Max Index: $maxIndex"); // 모델 예측 결과의 최대 인덱스 출력

    if (settingsProvider.Mode == 0) {
      if (maxIndex == 302 || maxIndex == 303) {
        setState(() {
          _detectionResult = "경적";
        });
        print("Notification: 경적");
        if (settingsProvider.Alarm == 1) {
          await _showNotification(_detectionResult);
        }
        await _triggerVibration2(settingsProvider.vibrationIntensity);
      } else if (maxIndex == 0 || maxIndex == 2) {
        setState(() {
          _detectionResult = "대화";
        });
        print("Notification: 대화");
        if (settingsProvider.Alarm == 1) {
          await _showNotification(_detectionResult);
        }
        await _triggerVibration2(settingsProvider.vibrationIntensity);
      } else if (maxIndex >= 316 && maxIndex <= 319 || maxIndex == 390) {
        setState(() {
          _detectionResult = "사이렌";
        });
        print("Notification: 사이렌");
        if (settingsProvider.Alarm == 1) {
          await _showNotification(_detectionResult);
        }
        await _triggerVibration2(settingsProvider.vibrationIntensity);
      } else if (maxIndex == 393 || maxIndex == 394) {
        setState(() {
          _detectionResult = "화재경보";
        });
        print("Notification: 화재경보");
        if (settingsProvider.Alarm == 1) {
          await _showNotification(_detectionResult);
        }
        await _triggerVibration2(settingsProvider.vibrationIntensity);
      } else if (maxIndex == 383) {
        setState(() {
          _detectionResult = "핸드폰 소리";
        });
        print("Notification: 핸드폰 소리");
        if (settingsProvider.Alarm == 1) {
          await _showNotification(_detectionResult);
        }
        await _triggerVibration(settingsProvider.vibrationIntensity);
      } else if (maxIndex == 382) {
        setState(() {
          _detectionResult = "알람 소리";
        });
        print("Notification: 알람 소리");
        if (settingsProvider.Alarm == 1) {
          await _showNotification(_detectionResult);
        }
        await _triggerVibration(settingsProvider.vibrationIntensity);
      } else {
        setState(() {
          _detectionResult = "잡음";
        });
        print("Notification: 잡음");
      }
    } else if (settingsProvider.Mode == 1) {
      if (maxIndex == 302 || maxIndex == 303) {
        setState(() {
          _detectionResult = "경적";
        });
        print("Notification: 경적");
        if (settingsProvider.Alarm == 1) {
          await _showNotification(_detectionResult);
        }
        await _triggerVibration2(settingsProvider.vibrationIntensity);
      } else if (maxIndex >= 316 && maxIndex <= 319 || maxIndex == 390) {
        setState(() {
          _detectionResult = "사이렌";
        });
        print("Notification: 사이렌");
        if (settingsProvider.Alarm == 1) {
          await _showNotification(_detectionResult);
        }
        await _triggerVibration2(settingsProvider.vibrationIntensity);
      } else {
        setState(() {
          _detectionResult = "잡음";
        });
        print("Notification: 잡음");
      }
    } else if (settingsProvider.Mode == 2) {
      if (maxIndex == 393 || maxIndex == 394) {
        setState(() {
          _detectionResult = "화재경보";
        });
        print("Notification: 화재경보");
        if (settingsProvider.Alarm == 1) {
          await _showNotification(_detectionResult);
        }
        await _triggerVibration2(settingsProvider.vibrationIntensity);
      } else if (maxIndex == 383) {
        setState(() {
          _detectionResult = "핸드폰 소리";
        });
        print("Notification: 핸드폰 소리");
        if (settingsProvider.Alarm == 1) {
          await _showNotification(_detectionResult);
        }
        await _triggerVibration(settingsProvider.vibrationIntensity);
      } else if (maxIndex == 382) {
        setState(() {
          _detectionResult = "알람 소리";
        });
        print("Notification: 알람 소리");
        if (settingsProvider.Alarm == 1) {
          await _showNotification(_detectionResult);
        }
        await _triggerVibration(settingsProvider.vibrationIntensity);
      } else {
        setState(() {
          _detectionResult = "잡음";
        });
        print("Notification: 잡음");
      }
    }
  }


  Future<void> _triggerVibration(double intensity) async {
    _isVibrating = true;
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(duration: (intensity * 100).toInt());
      await Future.delayed(Duration(milliseconds: 100));
      await Vibration.vibrate(duration: (intensity * 100).toInt());
      await Future.delayed(Duration(milliseconds: 100));
      await Vibration.vibrate(duration: (intensity * 100).toInt());
    }
    _isVibrating = false;
  }

  Future<void> _triggerVibration2(double intensity) async {
    _isVibrating = true;
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(duration: (intensity * 200).toInt());
      await Future.delayed(Duration(milliseconds: 200));
      await Vibration.vibrate(duration: (intensity * 200).toInt());
      await Future.delayed(Duration(milliseconds: 200));
      await Vibration.vibrate(duration: (intensity * 200).toInt());
    }
    _isVibrating = false;
  }

  void _startContinuousRecording() async {
    if (!_recorder.isStopped) {
      print("Recorder is already started or open, skipping openRecorder.");
      return;
    }

    try {
      await _recorder.openRecorder();
      _isRecording = true;

      await _recorder.startRecorder(
        toStream: _streamController.sink,
        codec: Codec.pcm16,
      );

      _streamController.stream.listen((Food foodData) {
        if (foodData is FoodData && _isRecording) {
          _onDataReceived(foodData);
        }
      });

      _timer = Timer.periodic(Duration(seconds: 2), (timer) {
        if (_pcmDataBuffer.isNotEmpty) {
          _processAudioData(Uint8List.fromList(_pcmDataBuffer));
          _pcmDataBuffer.clear();
        }
      });
    } catch (e) {
      print("Error starting the recorder: $e");
    }
  }

  void _onDataReceived(FoodData foodData) {
    _pcmDataBuffer.addAll(foodData.data!);
  }

  Float32List _convertToFloat32(Uint8List pcmData) {
    var buffer = Float32List(pcmData.length ~/ 2);
    for (int i = 0; i < pcmData.length; i += 2) {
      buffer[i ~/ 2] =
          (pcmData[i] | pcmData[i + 1] << 8).toSigned(16).toDouble() / 32768.0;
    }
    return buffer;
  }

  Float32List _adjustToInputShape(Float32List data, int targetSize) {
    if (data.length < targetSize) {
      return Float32List.fromList(
          data.toList() + List.filled(targetSize - data.length, 0.0));
    } else {
      return Float32List.fromList(data.sublist(0, targetSize));
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider =
    Provider.of<SettingsProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: DelightColors.background,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: ratio.height * 30),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: ratio.width * 10),
                  child: Text(
                    "Haptic Hear",
                    style: TextStyle(
                        color: DelightColors.darkgrey,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                  ),
                ),
                Spacer()
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.all(ratio.width * 10),
            padding: EdgeInsets.only(top: ratio.height * 35),
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    width: ratio.width * 3, color: DelightColors.grey1)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  _detectionResult,
                  style: TextStyle(
                      fontSize: 32,
                      color: DelightColors.grey1,
                      fontWeight: FontWeight.w900),
                ),
                Container(
                    height: ratio.height * 100, child: SoundWaveformWidget())
              ],
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: ratio.width * 10),
                child: Text("설정 관리",
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: DelightColors.mainBlue)),
              ),
              Spacer()
            ],
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.all(ratio.width * 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), color: Colors.white),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomUpDownCard(
                    title: "모드 전환",
                    value: settingsProvider.Mode,
                    onChanged: (value) {
                      setState(() {
                        settingsProvider.Mode = value;
                      });
                    },
                  ),
                  CustomSliderCard(
                    title: "진동세기",
                    value: settingsProvider.vibrationIntensity,
                    onChanged: (value) {
                      setState(() {
                        settingsProvider.vibrationIntensity = value;
                      });
                    },
                  ),
                  CustomUpDown2Card(
                    title: "백그라운드 알람 수신",
                    value: settingsProvider.Alarm,
                    onChanged: (value) {
                      setState(() {
                        settingsProvider.Alarm = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SoundWaveformWidget extends StatefulWidget {
  final int count;
  final double minHeight;
  final double maxHeight;
  final int durationInMilliseconds;
  const SoundWaveformWidget({
    Key? key,
    this.count = 6,
    this.minHeight = 10,
    this.maxHeight = 30,
    this.durationInMilliseconds = 500,
  }) : super(key: key);
  @override
  State<SoundWaveformWidget> createState() => _SoundWaveformWidgetState();
}

class _SoundWaveformWidgetState extends State<SoundWaveformWidget>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: widget.durationInMilliseconds,
        ))
      ..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.count;
    final minHeight = widget.minHeight;
    final maxHeight = widget.maxHeight;
    return AnimatedBuilder(
      animation: controller,
      builder: (c, child) {
        double t = controller.value;
        int current = (count * t).floor();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            count,
                (i) => AnimatedContainer(
              duration: Duration(
                  milliseconds: widget.durationInMilliseconds ~/ count),
              margin: i == (count - 1)
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(right: 5),
              height: i == current ? maxHeight : minHeight,
              width: 5,
              decoration: BoxDecoration(
                color: DelightColors.grey1,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
        );
      },
    );
  }
}
