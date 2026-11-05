import 'dart:math';

import '../models/sensor_data.dart';
import '../models/sensor_metrics.dart';

class SensorMetricsService {
  SensorMetrics calculate({
    required SensorData totalAccelerationData,
    required SensorData linearAccelerationData,
  }) {
    final accelerationMagnitude = _magnitude(
      totalAccelerationData.accelerometerX,
      totalAccelerationData.accelerometerY,
      totalAccelerationData.accelerometerZ,
    );

    final linearAccelerationMagnitude = _magnitude(
      linearAccelerationData.accelerometerX,
      linearAccelerationData.accelerometerY,
      linearAccelerationData.accelerometerZ,
    );

    final angularVelocityMagnitude = _magnitude(
      linearAccelerationData.gyroscopeX,
      linearAccelerationData.gyroscopeY,
      linearAccelerationData.gyroscopeZ,
    );

    return SensorMetrics(
      sensorData: linearAccelerationData,
      accelerationMagnitude: accelerationMagnitude,
      linearAccelerationX: linearAccelerationData.accelerometerX,
      linearAccelerationY: linearAccelerationData.accelerometerY,
      linearAccelerationZ: linearAccelerationData.accelerometerZ,
      linearAccelerationMagnitude: linearAccelerationMagnitude,
      angularVelocityMagnitude: angularVelocityMagnitude,
    );
  }

  double _magnitude(
    double x,
    double y,
    double z,
  ) {
    return sqrt(
      x * x +
          y * y +
          z * z,
    );
  }
}