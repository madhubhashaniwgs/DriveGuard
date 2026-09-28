import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';

import '../models/sensor_data.dart';

class SensorService {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;

  double _accelerometerX = 0;
  double _accelerometerY = 0;
  double _accelerometerZ = 0;

  double _gyroscopeX = 0;
  double _gyroscopeY = 0;
  double _gyroscopeZ = 0;

  double _magnetometerX = 0;
  double _magnetometerY = 0;
  double _magnetometerZ = 0;

  final StreamController<SensorData> _sensorDataController =
      StreamController<SensorData>.broadcast();

  Stream<SensorData> get sensorDataStream => _sensorDataController.stream;

  void start() {
    _accelerometerSubscription = accelerometerEventStream().listen(
      (event) {
        _accelerometerX = event.x;
        _accelerometerY = event.y;
        _accelerometerZ = event.z;

        _emitSensorData();
      },
    );

    _gyroscopeSubscription = gyroscopeEventStream().listen(
      (event) {
        _gyroscopeX = event.x;
        _gyroscopeY = event.y;
        _gyroscopeZ = event.z;

        _emitSensorData();
      },
    );

    _magnetometerSubscription = magnetometerEventStream().listen(
      (event) {
        _magnetometerX = event.x;
        _magnetometerY = event.y;
        _magnetometerZ = event.z;

        _emitSensorData();
      },
    );
  }

  void _emitSensorData() {
    _sensorDataController.add(
      SensorData(
        timestamp: DateTime.now(),

        accelerometerX: _accelerometerX,
        accelerometerY: _accelerometerY,
        accelerometerZ: _accelerometerZ,

        gyroscopeX: _gyroscopeX,
        gyroscopeY: _gyroscopeY,
        gyroscopeZ: _gyroscopeZ,

        magnetometerX: _magnetometerX,
        magnetometerY: _magnetometerY,
        magnetometerZ: _magnetometerZ,
      ),
    );
  }

  void stop() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _magnetometerSubscription?.cancel();

    _accelerometerSubscription = null;
    _gyroscopeSubscription = null;
    _magnetometerSubscription = null;
  }

  void dispose() {
    stop();
    _sensorDataController.close();
  }
}