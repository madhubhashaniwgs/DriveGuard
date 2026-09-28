import '../models/sensor_data.dart';

class SensorFilter {
  // Smoothing factor.
  // Smaller value = more smoothing.
  // Larger value = faster response.
  final double alpha;

  double? _accX;
  double? _accY;
  double? _accZ;

  double? _gyroX;
  double? _gyroY;
  double? _gyroZ;

  SensorFilter({
    this.alpha = 0.2,
  });

  SensorData filter(SensorData rawData) {
    _accX = _smooth(_accX, rawData.accelerometerX);
    _accY = _smooth(_accY, rawData.accelerometerY);
    _accZ = _smooth(_accZ, rawData.accelerometerZ);

    _gyroX = _smooth(_gyroX, rawData.gyroscopeX);
    _gyroY = _smooth(_gyroY, rawData.gyroscopeY);
    _gyroZ = _smooth(_gyroZ, rawData.gyroscopeZ);

    return SensorData(
      timestamp: rawData.timestamp,
      accelerometerX: _accX!,
      accelerometerY: _accY!,
      accelerometerZ: _accZ!,
      gyroscopeX: _gyroX!,
      gyroscopeY: _gyroY!,
      gyroscopeZ: _gyroZ!,
    );
  }

  double _smooth(double? previousValue, double currentValue) {
    if (previousValue == null) {
      return currentValue;
    }

    return alpha * currentValue +
        (1 - alpha) * previousValue;
  }

  void reset() {
    _accX = null;
    _accY = null;
    _accZ = null;

    _gyroX = null;
    _gyroY = null;
    _gyroZ = null;
  }
}