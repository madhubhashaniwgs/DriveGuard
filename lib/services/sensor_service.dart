import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';

class SensorData {
  final double x;
  final double y;
  final double z;

  SensorData({
    required this.x,
    required this.y,
    required this.z,
  });
}

class SensorService {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  final StreamController<SensorData> _accelerometerController =
      StreamController<SensorData>.broadcast();

  final StreamController<SensorData> _gyroscopeController =
      StreamController<SensorData>.broadcast();

  Stream<SensorData> get accelerometerStream =>
      _accelerometerController.stream;

  Stream<SensorData> get gyroscopeStream => _gyroscopeController.stream;

  void startSensors() {
    _startAccelerometer();
    _startGyroscope();
  }

  void _startAccelerometer() {
    _accelerometerSubscription =
        accelerometerEventStream().listen((AccelerometerEvent event) {
      _accelerometerController.add(
        SensorData(
          x: event.x,
          y: event.y,
          z: event.z,
        ),
      );
    });
  }

  void _startGyroscope() {
    _gyroscopeSubscription =
        gyroscopeEventStream().listen((GyroscopeEvent event) {
      _gyroscopeController.add(
        SensorData(
          x: event.x,
          y: event.y,
          z: event.z,
        ),
      );
    });
  }

  void stopSensors() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;

    _gyroscopeSubscription?.cancel();
    _gyroscopeSubscription = null;
  }

  void dispose() {
    stopSensors();

    _accelerometerController.close();
    _gyroscopeController.close();
  }
}

