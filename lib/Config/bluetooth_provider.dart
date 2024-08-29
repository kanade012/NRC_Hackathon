import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BluetoothManager with ChangeNotifier {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  StreamSubscription<List<int>>? _dataSubscription;
  DiscoveredDevice? connectedDevice;
  bool isConnected = false;

  QualifiedCharacteristic? _characteristic;
  QualifiedCharacteristic? get connectedCharacteristic => _characteristic;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  BluetoothManager() {
    _initializeNotifications();
  }

  // Initialize local notifications
  void _initializeNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        String? payload = response.payload;
        print('Notification selected: $payload');
      },
    );
  }

  // Connect to a Bluetooth device
  Future<bool> connectToDevice(DiscoveredDevice device) async {
    try {
      _connectionSubscription?.cancel();
      _connectionSubscription = _ble.connectToDevice(id: device.id).listen(
            (connectionState) {
          if (connectionState.connectionState == DeviceConnectionState.connected) {
            connectedDevice = device;
            isConnected = true;
            _discoverServices(device); // Discover services and characteristics
            notifyListeners();
          } else if (connectionState.connectionState == DeviceConnectionState.disconnected) {
            _handleDisconnection();
          }
        },
        onError: (error) {
          _handleError(error);
        },
      );

      await Future.delayed(const Duration(seconds: 3)); // Wait to confirm connection
      return isConnected;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // Discover services and characteristics
  Future<void> _discoverServices(DiscoveredDevice device) async {
    try {
      final services = await _ble.discoverServices(device.id);

      for (var service in services) {
        print("Service: ${service.serviceId}");
        for (var characteristic in service.characteristics) {
          print("Characteristic: ${characteristic.characteristicId}");

          if (characteristic.isWritableWithResponse || characteristic.isWritableWithoutResponse) {
            _characteristic = QualifiedCharacteristic(
              serviceId: service.serviceId,
              characteristicId: characteristic.characteristicId,
              deviceId: device.id,
            );
            print("Writable characteristic found: ${characteristic.characteristicId}");

            // Start listening to the device for data
            _startListeningToDevice();
            return;
          }
        }
      }

      print("No writable characteristic found.");
    } catch (e) {
      print("Service discovery error: $e");
    }
  }

  Function(String)? onDataReceived;

  // Start listening to the device for data
  void _startListeningToDevice() {
    if (_characteristic != null) {
      _dataSubscription?.cancel();
      _dataSubscription = _ble.subscribeToCharacteristic(_characteristic!).listen((data) {
        String receivedData = String.fromCharCodes(data);
        print("Data received: $receivedData");

        if (onDataReceived != null) {
          onDataReceived!(receivedData);
        }

        _showNotification(receivedData);
      }, onError: (error) {
        print("Data subscription error: $error");
      });
    } else {
      print("No characteristic set for listening.");
    }
  }


  // Show a local notification
  Future<void> _showNotification(String message) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'bluetooth_channel_id',
      'Bluetooth Notifications',
      channelDescription: 'Notifications for data received via Bluetooth',
      importance: Importance.max,
      priority: Priority.high,
    );

    const platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Received Data',
      message,
      platformChannelSpecifics,
      payload: 'Bluetooth Data',
    );
  }

  // Write data to the connected device
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

  // Disconnect from the device
  Future<bool> disconnectDevice() async {
    try {
      await _connectionSubscription?.cancel();
      await _dataSubscription?.cancel();
      _handleDisconnection();
      return true;
    } catch (e) {
      print('Disconnection error: $e');
      return false;
    }
  }

  // Handle disconnection logic
  void _handleDisconnection() {
    connectedDevice = null;
    isConnected = false;
    _characteristic = null;
    notifyListeners();
  }

  // Handle connection errors
  void _handleError(Object error) {
    print('Connection error: $error');
    disconnectDevice();
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _dataSubscription?.cancel();
    super.dispose();
  }
}
