import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter/material.dart';

class BluetoothManager with ChangeNotifier {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  DiscoveredDevice? connectedDevice;
  bool isConnected = false;

  QualifiedCharacteristic? _characteristic;

  Future<bool> connectToDevice(DiscoveredDevice device) async {
    try {
      _connectionSubscription?.cancel();
      _connectionSubscription = _ble.connectToDevice(id: device.id).listen(
            (connectionState) {
          if (connectionState.connectionState == DeviceConnectionState.connected) {
            connectedDevice = device;
            isConnected = true;
            notifyListeners();
          } else if (connectionState.connectionState == DeviceConnectionState.disconnected) {
            connectedDevice = null;
            isConnected = false;
            _characteristic = null;
            notifyListeners();
          }
        },
        onError: (error) {
          _handleError(error);
        },
      );

      // 연결 상태를 확인하기 위해 일정 시간 대기
      await Future.delayed(Duration(seconds: 3));
      return isConnected;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // connectedCharacteristic Getter
  QualifiedCharacteristic? get connectedCharacteristic => _characteristic;

  // writeData 메서드
  Future<void> writeData(String data) async {
    if (_characteristic != null) {
      try {
        await _ble.writeCharacteristicWithResponse(
          _characteristic!,
          value: data.codeUnits,
        );
        print("Data sent: $data");
      } catch (e) {
        print("Write data error: $e");
      }
    } else {
      print("Characteristic is not set.");
    }
  }

  Future<bool> disconnectDevice() async {
    try {
      _connectionSubscription?.cancel();
      connectedDevice = null;
      isConnected = false;
      _characteristic = null;
      notifyListeners();
      return true;
    } catch (e) {
      print('Disconnection error: $e');
      return false;
    }
  }

  void _handleError(Object error) {
    print('Connection error: $error');
    disconnectDevice();
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    super.dispose();
  }
}
