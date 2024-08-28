import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:delight/Config/bluetooth_provider.dart';
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
    setState(() {
      vibration = prefs.getDouble('vibration') ?? 1.0;
      brightness = prefs.getDouble('brightness') ?? 1.0;
      transitionTime = prefs.getInt('transitionTime') ?? 3;
      textSize = prefs.getDouble('textSize') ?? 14.0;
    });
  }

  Future<void> _sendDataToArduino(String data) async {
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
    if (bluetoothManager.isConnected) {
      final characteristic = bluetoothManager.connectedCharacteristic;
      if (characteristic != null) {
        await bluetoothManager.writeData(data);
      } else {
        print("Characteristic is null.");
      }
    } else {
      print("Bluetooth is not connected.");
    }
  }

  Future<void> _uploadAllSettings() async {
    await _loadSettings();
    await _sendDataToArduino("vibration:$vibration");
    await _sendDataToArduino("brightness:$brightness");
    await _sendDataToArduino("transitionTime:$transitionTime");
    await _sendDataToArduino("textSize:$textSize");
    print("All settings uploaded");
  }

  void _updateVibration(double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('vibration', value);
    await _sendDataToArduino("vibration:$value");
    setState(() {
      vibration = value;
    });
  }

  void _updateBrightness(double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('brightness', value);
    await _sendDataToArduino("brightness:$value");
    setState(() {
      brightness = value;
    });
  }

  void _updateTransitionTime(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('transitionTime', value);
    await _sendDataToArduino("transitionTime:$value");
    setState(() {
      transitionTime = value;
    });
  }

  void _updateTextSize(double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textSize', value);
    await _sendDataToArduino("textSize:$value");
    setState(() {
      textSize = value;
    });
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
              return _buildSettingsUI(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSettingsUI(BuildContext context) {
    final bluetoothManager = Provider.of<BluetoothManager>(context);

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
                  borderRadius: BorderRadius.circular(12), color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "연결상태 :",
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(
                      width: ratio.width * 10,
                    ),
                    if (bluetoothManager.isConnected)
                      GestureDetector(
                        onTap: () async {
                          await _loadSettings();
                          await bluetoothManager.disconnectDevice();
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: ratio.height * 7),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(width: 2, color: DelightColors.mainBlue),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child: Text(
                              bluetoothManager.connectedDevice?.name ?? "Unknown",
                              style: TextStyle(
                                color: DelightColors.mainBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            await _loadSettings();
                            await bluetoothManager.disconnectDevice();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BluetoothDeviceListScreen(
                                  onDeviceConnected: _uploadAllSettings,
                                ),
                              ),
                            );

                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: ratio.height * 7),
                            child: Container(
                              padding: EdgeInsets.all(ratio.width * 10),
                              child: Text(
                                "연결하러가기",
                                style: TextStyle(
                                  color: DelightColors.mainBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              decoration: BoxDecoration(
                                  border: Border.all(width: 2, color: DelightColors.mainBlue),
                                  borderRadius: BorderRadius.circular(5)
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: ratio.height * 15),
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
                  borderRadius: BorderRadius.circular(12), color: Colors.white),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomSliderCard(title: "진동", value: vibration, onChanged: _updateVibration),
                    CustomSlider2Card(title: "밝기", value: brightness, onChanged: _updateBrightness),
                    CustomUpDownCard(title: "전환 시간", value: transitionTime, onChanged: _updateTransitionTime),
                    CustomUpDown2Card(title: "텍스트 크기", value: textSize, onChanged: _updateTextSize),
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
  final double value;
  final ValueChanged<double> onChanged;

  CustomSliderCard({
    required this.title,
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  State<CustomSliderCard> createState() => _CustomSliderCardState();
}

class _CustomSliderCardState extends State<CustomSliderCard> {
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
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}

class CustomSlider2Card extends StatefulWidget {
  final String title;
  final double value;
  final ValueChanged<double> onChanged;

  CustomSlider2Card({
    required this.title,
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  State<CustomSlider2Card> createState() => _CustomSlider2CardState();
}

class _CustomSlider2CardState extends State<CustomSlider2Card> {
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
            onChanged: widget.onChanged,
          ),
        ],
      ),
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
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
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
                    setState(() {
                      _currentValue--;
                    });
                    widget.onChanged(_currentValue);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 3, color: DelightColors.mainBlue)),
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
                  setState(() {
                    _currentValue++;
                  });
                  widget.onChanged(_currentValue);
                },
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 3, color: DelightColors.mainBlue)),
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
  final ValueChanged<double> onChanged;

  CustomUpDown2Card({
    required this.title,
    required this.value,
    required this.onChanged,
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
                  if (_currentValue > 1) {
                    setState(() {
                      _currentValue--;
                    });
                    widget.onChanged(_currentValue);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 3, color: DelightColors.mainBlue)),
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
                  setState(() {
                    _currentValue++;
                  });
                  widget.onChanged(_currentValue);
                },
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 3, color: DelightColors.mainBlue)),
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
  final VoidCallback onDeviceConnected;

  BluetoothDeviceListScreen({required this.onDeviceConnected});

  @override
  _BluetoothDeviceListScreenState createState() => _BluetoothDeviceListScreenState();
}

class _BluetoothDeviceListScreenState extends State<BluetoothDeviceListScreen> {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  late StreamSubscription<DiscoveredDevice> _scanSubscription;
  List<DiscoveredDevice> devicesList = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndStartScan();
  }

  Future<void> _checkPermissionsAndStartScan() async {
    if (await _requestPermissions()) {
      startScan();
    } else {
      startScan();
    }
  }

  Future<bool> _requestPermissions() async {
    final status = await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    return status.values.every((status) => status.isGranted);
  }

  void startScan() {
    if (mounted)
      setState(() {
        isScanning = true;
        devicesList.clear();
      });

    _scanSubscription = _ble.scanForDevices(withServices: []).listen((device) {
      if (!devicesList.any((d) => d.id == device.id)) {
        if (mounted)
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
    if (mounted)
      setState(() {
        isScanning = false;
      });
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  void dispose() {
    _scanSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothManager = Provider.of<BluetoothManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('기기 검색'),
      ),
      body: ListView.builder(
        itemCount: devicesList.length,
        itemBuilder: (context, index) {
          final device = devicesList[index];
          final isConnected = bluetoothManager.connectedDevice?.id == device.id;

          return ListTile(
            title: Text(device.name.isNotEmpty ? device.name : 'Unknown Device'),
            subtitle: Text(device.id),
            trailing: isConnected ? Icon(Icons.link, color: Colors.green) : null,
            onTap: () async {
              if (isConnected) {
                bool success = await bluetoothManager.disconnectDevice();
                if (success) {
                  showMessage('${device.name.isNotEmpty ? device.name : 'Device'} disconnected');
                } else {
                  showMessage('Failed to disconnect from ${device.name.isNotEmpty ? device.name : 'Device'}');
                }
              } else {
                bool success = await bluetoothManager.connectToDevice(device);
                if (success) {
                  widget.onDeviceConnected();  // Call the passed callback
                  showMessage('${device.name.isNotEmpty ? device.name : 'Device'} connected');
                } else {
                  showMessage('Failed to connect to ${device.name.isNotEmpty ? device.name : 'Device'}');
                }
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: DelightColors.mainBlue,
        onPressed: () => isScanning ? stopScan() : startScan(),
        child: Icon(isScanning ? Icons.stop : Icons.search, color: Colors.white,),
      ),
    );
  }
}
