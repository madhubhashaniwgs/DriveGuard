import 'dart:math';

import '../models/motion_calibration.dart';

class MotionCalibrationService {
  MotionCalibration? _calibration;

  MotionCalibration? get calibration => _calibration;

  bool get isCalibrated => _calibration != null;

  void calibratePhoneTopAsForward() {
    _calibration = const MotionCalibration(
      forwardX: 0,
      forwardY: 1,
      forwardZ: 0,
    );
  }

  double calculateLongitudinalAcceleration({
    required double accelerationX,
    required double accelerationY,
    required double accelerationZ,
  }) {
    if (_calibration == null) {
      return 0;
    }

    return _calibration!.calculateLongitudinalAcceleration(
      accelerationX,
      accelerationY,
      accelerationZ,
    );
  }

  void setCalibration({
    required double forwardX,
    required double forwardY,
    required double forwardZ,
  }) {
    final magnitude = sqrt(
      forwardX * forwardX +
          forwardY * forwardY +
          forwardZ * forwardZ,
    );

    if (magnitude == 0) {
      return;
    }

    _calibration = MotionCalibration(
      forwardX: forwardX / magnitude,
      forwardY: forwardY / magnitude,
      forwardZ: forwardZ / magnitude,
    );
  }

  void reset() {
    _calibration = null;
  }
}