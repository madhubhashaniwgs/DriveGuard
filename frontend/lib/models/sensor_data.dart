class SensorData {
  final DateTime timestamp;

  // Accelerometer
  final double accelerometerX;
  final double accelerometerY;
  final double accelerometerZ;

  // Gyroscope
  final double gyroscopeX;
  final double gyroscopeY;
  final double gyroscopeZ;

  // Magnetometer
  final double magnetometerX;
  final double magnetometerY;
  final double magnetometerZ;

  const SensorData({
    required this.timestamp,

    required this.accelerometerX,
    required this.accelerometerY,
    required this.accelerometerZ,

    required this.gyroscopeX,
    required this.gyroscopeY,
    required this.gyroscopeZ,

    this.magnetometerX = 0,
    this.magnetometerY = 0,
    this.magnetometerZ = 0,
  });
}