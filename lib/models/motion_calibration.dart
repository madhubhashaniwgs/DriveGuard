class MotionCalibration {
  final double forwardX;
  final double forwardY;
  final double forwardZ;

  const MotionCalibration({
    required this.forwardX,
    required this.forwardY,
    required this.forwardZ,
  });

  double calculateLongitudinalAcceleration(
    double accelerationX,
    double accelerationY,
    double accelerationZ,
  ) {
    return accelerationX * forwardX +
        accelerationY * forwardY +
        accelerationZ * forwardZ;
  }
}