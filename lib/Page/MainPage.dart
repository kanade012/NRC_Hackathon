import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Config/color.dart';
import '../main.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double vibration = 1;
  double brightness = 1;
  int transitionTime = 3;
  double textSize = 14;

  late Future<void> _loadSettingsFuture;

  @override
  void initState() {
    super.initState();
    _loadSettingsFuture = _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    vibration = prefs.getDouble('vibration') ?? 1.0;
    brightness = prefs.getDouble('brightness') ?? 1.0;
    transitionTime = prefs.getInt('transitionTime') ?? 3;
    textSize = prefs.getDouble('textSize') ?? 14.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DelightColors.background,
      body: SafeArea(
        child: FutureBuilder(
          future: _loadSettingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              return _buildSettingsUI();
            }
          },
        ),
      ),
    );
  }

  Widget _buildSettingsUI() {
    return Padding(
      padding: EdgeInsets.all(ratio.width * 15),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Delight",
                    style: TextStyle(
                        color: DelightColors.darkgrey,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic)),
              ],
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BluetoothDeviceListScreen()));
                      },
                      child: Text("연결하러가기"),
                    )),
              ),
            ),
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
                  color: Colors.white),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomSliderCard(title: "진동", value: vibration),
                    CustomSlider2Card(title: "밝기", value: brightness),
                    CustomUpDownCard(title: "전환 시간", value: transitionTime),
                    CustomUpDown2Card(title: "텍스트 크기", value: textSize),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomSliderCard extends StatefulWidget {
  final String title;
  double value;

  CustomSliderCard({
    required this.title,
    required this.value,
    super.key,
  });

  @override
  State<CustomSliderCard> createState() => _CustomSliderCardState();
}

class _CustomSliderCardState extends State<CustomSliderCard> {
  void _updateVibration(double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('vibration', value);
    setState(() {
      widget.value = value;
    });
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title,
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: DelightColors.mainBlue)),
          Slider(
            activeColor: DelightColors.mainBlue,
            inactiveColor: DelightColors.subBlue,
            value: widget.value,
            max: 10,
            label: widget.value.round().toString(),
            divisions: 10,
            onChanged: (value) {
              _updateVibration(value);
            },
          ),
        ],
      ),
    );
  }
}

class CustomSlider2Card extends StatefulWidget {
  final String title;
  double value;

  CustomSlider2Card({
    required this.title,
    required this.value,
    super.key,
  });

  @override
  State<CustomSlider2Card> createState() => _CustomSlider2CardState();
}

class _CustomSlider2CardState extends State<CustomSlider2Card> {
  void _updateBrightness(double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('brightness', value);
    setState(() {
      widget.value = value;
    });
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title,
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: DelightColors.mainBlue)),
          Slider(
            activeColor: DelightColors.mainBlue,
            inactiveColor: DelightColors.subBlue,
            value: widget.value,
            max: 10,
            label: widget.value.round().toString(),
            divisions: 10,
            onChanged: (value) {
              _updateBrightness(value);
            },
          ),
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
    _currentValue = widget.value;
  }

  void _updateTransitionTime(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('transitionTime', value);
    setState(() {
      _currentValue = value;
    });
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  if (_currentValue > 0) {
                    _updateTransitionTime(_currentValue - 1);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 3, color: DelightColors.mainBlue)),
                  child: Icon(
                    CupertinoIcons.minus,
                    color: DelightColors.mainBlue,
                    size: 40,
                  ),
                ),
              ),
              Text('$_currentValue',
                  style: TextStyle(
                    fontSize: 40,
                    color: DelightColors.mainBlue,
                  )),
              GestureDetector(
                onTap: () {
                  _updateTransitionTime(_currentValue + 1);
                },
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 3, color: DelightColors.mainBlue)),
                    child: Icon(
                      CupertinoIcons.plus,
                      color: DelightColors.mainBlue,
                      size: 40,
                    )),
              ),
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
    _currentValue = widget.value;
  }

  void _updateTextSize(double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textSize', value);
    setState(() {
      _currentValue = value;
    });
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  _updateTextSize(_currentValue - 1.0);
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 3, color: DelightColors.mainBlue)),
                  child: Icon(
                    CupertinoIcons.minus,
                    color: DelightColors.mainBlue,
                    size: 40,
                  ),
                ),
              ),
              Text('가',
                  style: TextStyle(
                    fontSize: _currentValue,
                    color: DelightColors.mainBlue,
                  )),
              GestureDetector(
                onTap: () {
                  _updateTextSize(_currentValue + 1.0);
                },
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 3, color: DelightColors.mainBlue)),
                    child: Icon(
                      CupertinoIcons.plus,
                      color: DelightColors.mainBlue,
                      size: 40,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BluetoothDeviceListScreen extends StatefulWidget {
  @override
  _BluetoothDeviceListScreenState createState() =>
      _BluetoothDeviceListScreenState();
}

class _BluetoothDeviceListScreenState
    extends State<BluetoothDeviceListScreen> {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  late StreamSubscription<DiscoveredDevice> _scanSubscription;
  List<DiscoveredDevice> devicesList = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    startScan();
  }

  @override
  void dispose() {
    _scanSubscription.cancel();
    super.dispose();
  }

  void startScan() async {
    // 권한 요청
    bool permissionsGranted = await _requestPermissions();
    if (!permissionsGranted) {
      showMessage('Permissions not granted.');
      return;
    }

    if (isScanning) return;

    setState(() {
      isScanning = true;
      devicesList.clear();
    });

    _scanSubscription = _ble.scanForDevices(withServices: []).listen((device) {
      if (!devicesList.any((d) => d.id == device.id)) {
        setState(() {
          devicesList.add(device);
        });
      }
    }, onError: (error) {
      showMessage('Scan error: $error');
      stopScan();
    });

    Future.delayed(Duration(seconds: 5), () {
      stopScan();
    });
  }

  void stopScan() {
    if (!isScanning) return;

    _scanSubscription.cancel();
    setState(() {
      isScanning = false;
    });
  }

  Future<bool> _requestPermissions() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.locationWhenInUse,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (!allGranted) {
      showMessage('One or more permissions were not granted: $statuses');
    }

    return allGranted;
  }
  void connectToDevice(DiscoveredDevice device) async {
    try {
      final connection = _ble.connectToDevice(id: device.id);
      connection.listen(
            (connectionState) {
          if (connectionState.connectionState ==
              DeviceConnectionState.connected) {
            showMessage('Connected to ${device.name}');
          } else if (connectionState.connectionState ==
              DeviceConnectionState.disconnected) {
            showMessage('Disconnected from ${device.name}');
          }
        },
        onError: (error) {
          showMessage('Connection error: $error');
        },
      );
    } catch (e) {
      showMessage('Failed to connect: $e');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Devices'),
      ),
      body: ListView.builder(
        itemCount: devicesList.length,
        itemBuilder: (context, index) {
          final device = devicesList[index];
          return ListTile(
            title: Text(device.name.isNotEmpty ? device.name : 'Unknown Device'),
            subtitle: Text(device.id),
            onTap: () => connectToDevice(device),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => isScanning ? stopScan() : startScan(),
        child: Icon(isScanning ? Icons.stop : Icons.search),
      ),
    );
  }
}