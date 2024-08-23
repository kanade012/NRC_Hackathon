import 'package:flutter/material.dart';
import 'Page/MainPage.dart';

late Size ratio;

void main() {
  runApp(MyApp());
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
// class SettingsPage extends StatefulWidget {
//   @override
//   _SettingsPageState createState() => _SettingsPageState();
// }
//
// class _SettingsPageState extends State<SettingsPage> {
//   double vibration = 0;
//   double brightness = 0;
//   double transitionTime = 0;
//   double textSize = 14;
//
//   BluetoothDevice? connectedDevice;
//   BluetoothCharacteristic? characteristic;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSettings();
//     _connectToDevice();
//   }
//
//   Future<void> _loadSettings() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       vibration = prefs.getDouble('vibration') ?? 0;
//       brightness = prefs.getDouble('brightness') ?? 0;
//       transitionTime = prefs.getDouble('transitionTime') ?? 0;
//       textSize = prefs.getDouble('textSize') ?? 14;
//     });
//   }
//
//   Future<void> _saveSettings() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setDouble('vibration', vibration);
//     prefs.setDouble('brightness', brightness);
//     prefs.setDouble('transitionTime', transitionTime);
//     prefs.setDouble('textSize', textSize);
//   }
//
//   void _connectToDevice() async {
//     FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
//
//     FlutterBluePlus.scanResults.listen((results) async {
//       for (ScanResult r in results) {
//         if (r.device.name == "YourDeviceName") { // Replace with your device name
//           FlutterBluePlus.stopScan();
//           try {
//             await r.device.connect();
//             setState(() {
//               connectedDevice = r.device;
//             });
//
//             List<BluetoothService> services = await connectedDevice!.discoverServices();
//             services.forEach((service) {
//               for (BluetoothCharacteristic c in service.characteristics) {
//                 if (c.uuid.toString() == "your-characteristic-uuid") { // Replace with your characteristic UUID
//                   characteristic = c;
//                 }
//               }
//             });
//           } catch (e) {
//             print("Failed to connect: $e");
//           }
//         }
//       }
//     });
//   }
//
//   void _sendDataToArduino() {
//     if (connectedDevice != null && characteristic != null) {
//       String data =
//           "$vibration,$brightness,$transitionTime,$textSize";
//       List<int> bytes = data.codeUnits;
//
//       characteristic!.write(bytes);
//       print("Data sent: $data");
//     }
//   }
//
//   Widget _buildSlider(String label, double value, ValueChanged<double> onChanged) {
//     return Column(
//       children: [
//         Text(label),
//         Slider(
//           value: value,
//           min: 0,
//           max: 100,
//           divisions: 100,
//           label: value.round().toString(),
//           onChanged: onChanged,
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Settings'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _buildSlider('Vibration', vibration, (value) {
//               setState(() {
//                 vibration = value;
//               });
//               _saveSettings();
//               _sendDataToArduino();
//             }),
//             _buildSlider('Brightness', brightness, (value) {
//               setState(() {
//                 brightness = value;
//               });
//               _saveSettings();
//               _sendDataToArduino();
//             }),
//             _buildSlider('Transition Time', transitionTime, (value) {
//               setState(() {
//                 transitionTime = value;
//               });
//               _saveSettings();
//               _sendDataToArduino();
//             }),
//             _buildSlider('Text Size', textSize, (value) {
//               setState(() {
//                 textSize = value;
//               });
//               _saveSettings();
//               _sendDataToArduino();
//             }),
//           ],
//         ),
//       ),
//     );
//   }
// }
