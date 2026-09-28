import 'dart:math';

import '../models/sensor_data.dart';
import '../models/sensor_metrics.dart';

class SensorMetricsService {
  SensorMetrics calculate(SensorData data) {
    final accelerationMagnitude = sqrt(
      pow(data.accelerometerX, 2) +
          pow(data.accelerometerY, 2) +
          pow(data.accelerometerZ, 2),
    );

    final angularVelocityMagnitude = sqrt(
      pow(data.gyroscopeX, 2) +
          pow(data.gyroscopeY, 2) +
          pow(data.gyroscopeZ, 2),
    );

    return SensorMetrics(
      sensorData: data,
      accelerationMagnitude: accelerationMagnitude,
      angularVelocityMagnitude: angularVelocityMagnitude,
    );
  }
}