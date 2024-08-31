import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import '../Config/Setting_Provider.dart';
import '../Config/color.dart';
import '../main.dart';
import 'MainPage.dart';

class Alarm extends StatefulWidget {
  const Alarm({super.key});

  @override
  State<Alarm> createState() => _AlarmState();
}

class _AlarmState extends State<Alarm> {
  late String _timeString;
  String _detectionResult = "Noise";
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  late Interpreter _interpreter;
  late TensorBuffer _inputBuffer;
  late TensorBuffer _outputBuffer;
  List<int> _pcmDataBuffer = [];
  bool _isRecording = false;
  Timer? _timer;
  StreamController<Food> _streamController = StreamController<Food>();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _initializeInterpreter();
    _timeString = _formatTime(DateTime.now());
    Timer.periodic(Duration(seconds: 2), (Timer t) => _getTime());
  }

  Future<void> _initializeInterpreter() async {
    try {
      _interpreter = await Interpreter.fromAsset('model.tflite');
      _inputBuffer = TensorBuffer.createFixedSize([1, 1640], TfLiteType.float32);
      _outputBuffer = TensorBuffer.createFixedSize([1, 6], TfLiteType.float32); // Updated to match model output shape
      _startContinuousRecording();
    } catch (e) {
      print("Error initializing interpreter: $e");
    }
  }

  void _startContinuousRecording() async {
    await Permission.microphone.request();

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
  }

  void _onDataReceived(FoodData foodData) {
    _pcmDataBuffer.addAll(foodData.data!);
  }

  void _processAudioData(Uint8List pcmData) {
    Float32List floatBuffer = _convertToFloat32(pcmData);

    // 윈도우 크기와 shape을 정확히 맞춤
    if (floatBuffer.length != 1640) {
      floatBuffer = _adjustToInputShape(floatBuffer, 1640);
    }

    _inputBuffer.loadList(floatBuffer, shape: [1, 1640]);
    _interpreter.run(_inputBuffer.buffer, _outputBuffer.buffer);

    List<double> outputData = _outputBuffer.getDoubleList();
    print("Model output: $outputData");

    _handleModelOutput(outputData);
  }

  Float32List _convertToFloat32(Uint8List pcmData) {
    var buffer = Float32List(pcmData.length ~/ 2);
    for (int i = 0; i < pcmData.length; i += 2) {
      buffer[i ~/ 2] = (pcmData[i] | pcmData[i + 1] << 8).toSigned(16).toDouble() / 32768.0;
    }
    return buffer;
  }

  Float32List _adjustToInputShape(Float32List data, int targetSize) {
    if (data.length < targetSize) {
      return Float32List.fromList(data.toList() + List.filled(targetSize - data.length, 0.0));
    } else {
      return Float32List.fromList(data.sublist(0, targetSize));
    }
  }

  void _handleModelOutput(List<double> outputData) {
    int maxIndex = outputData.indexOf(outputData.reduce((a, b) => a > b ? a : b));

    setState(() {
      if (maxIndex == 0) {
        _detectionResult = "Fire";
      } else if (maxIndex == 1) {
        _detectionResult = "Horn";
      } else if (maxIndex == 2) {
        _detectionResult = "Noise";
      } else if (maxIndex == 3) {
        _detectionResult = "Knock";
      } else if (maxIndex == 4) {
        _detectionResult = "Noise";
      } else if (maxIndex == 5) {
        _detectionResult = "Siren";
      }
    });
  }

  @override
  void dispose() {
    _isRecording = false;
    _timer?.cancel();
    _recorder.stopRecorder();
    _recorder.closeRecorder();
    _interpreter.close();
    _streamController.close();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final settingsProvider =
    Provider.of<SettingsProvider>(context, listen: false);
    setState(() {
      settingsProvider.vibrationIntensity =
          prefs.getDouble('vibrationIntensity') ?? 1.0;
      settingsProvider.brightness = prefs.getDouble('brightness') ?? 1.0;
      settingsProvider.textSize = prefs.getDouble('textSize') ?? 26.0;
      settingsProvider.transitionTime = prefs.getInt('transitionTime') ?? 1;
    });
    _updateBrightness(settingsProvider.brightness);
  }

  Future<void> _updateBrightness(double brightness) async {
    try {
      double normalizedBrightness = brightness / 10.0;
      await ScreenBrightness().setScreenBrightness(normalizedBrightness);
    } catch (e) {
      print("Failed to set brightness: $e");
    }
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedTime = _formatTime(now);
    if (mounted) {
      setState(() {
        _timeString = formattedTime;
      });
    }
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider =
    Provider.of<SettingsProvider>(context, listen: false);
    return PageView(
      children: [
        Scaffold(
          backgroundColor: DelightColors.background,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    _timeString,
                    style: TextStyle(
                        fontSize: ratio.height * 120,
                        color: DelightColors.grey1,
                        fontWeight: FontWeight.w900),
                  ),
                  Divider(
                    color: Colors.black,
                    indent: 65,
                    endIndent: 65,
                  ),
                ],
              ),
              Text(
                _detectionResult,
                style: TextStyle(
                    fontSize: settingsProvider.textSize,
                    color: DelightColors.grey1,
                    fontWeight: FontWeight.w900),
              ),
              Container(
                  height: ratio.height * 100, child: SoundWaveformWidget())
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => MainPage()));
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
      ],
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
