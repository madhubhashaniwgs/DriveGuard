import 'sensor_data.dart';

class SensorMetrics {
  final SensorData sensorData;

  // Total acceleration including gravity
  final double accelerationMagnitude;

  // Acceleration after removing gravity
  final double linearAccelerationX;
  final double linearAccelerationY;
  final double linearAccelerationZ;
  final double linearAccelerationMagnitude;

  // Rotation speed
  final double angularVelocityMagnitude;

  const SensorMetrics({
    required this.sensorData,
    required this.accelerationMagnitude,
    required this.linearAccelerationX,
    required this.linearAccelerationY,
    required this.linearAccelerationZ,
    required this.linearAccelerationMagnitude,
    required this.angularVelocityMagnitude,
  });
}