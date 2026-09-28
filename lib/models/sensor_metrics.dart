import 'sensor_data.dart';

class SensorMetrics {
  final SensorData sensorData;
  final double accelerationMagnitude;
  final double angularVelocityMagnitude;

  const SensorMetrics({
    required this.sensorData,
    required this.accelerationMagnitude,
    required this.angularVelocityMagnitude,
  });
}