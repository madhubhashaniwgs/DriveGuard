import '../models/sensor_data.dart';

class GravityEstimator {
  final double alpha;

  double? _gravityX;
  double? _gravityY;
  double? _gravityZ;

  GravityEstimator({
    this.alpha = 0.1,
  });

  SensorData removeGravity(SensorData data) {
    _gravityX = _estimate(
      _gravityX,
      data.accelerometerX,
    );

    _gravityY = _estimate(
      _gravityY,
      data.accelerometerY,
    );

    _gravityZ = _estimate(
      _gravityZ,
      data.accelerometerZ,
    );

    return SensorData(
      timestamp: data.timestamp,

      accelerometerX:
          data.accelerometerX - _gravityX!,
      accelerometerY:
          data.accelerometerY - _gravityY!,
      accelerometerZ:
          data.accelerometerZ - _gravityZ!,

      gyroscopeX: data.gyroscopeX,
      gyroscopeY: data.gyroscopeY,
      gyroscopeZ: data.gyroscopeZ,

      magnetometerX: data.magnetometerX,
      magnetometerY: data.magnetometerY,
      magnetometerZ: data.magnetometerZ,
    );
  }

  double _estimate(
    double? previousGravity,
    double currentValue,
  ) {
    if (previousGravity == null) {
      return currentValue;
    }

    return alpha * currentValue +
        (1 - alpha) * previousGravity;
  }

  void reset() {
    _gravityX = null;
    _gravityY = null;
    _gravityZ = null;
  }
}