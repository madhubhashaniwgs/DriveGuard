import 'dart:math';

import '../models/sensor_data.dart';

class OrientationVector {
  final double x;
  final double y;
  final double z;

  const OrientationVector({
    required this.x,
    required this.y,
    required this.z,
  });

  double dot(OrientationVector other) {
    return x * other.x + y * other.y + z * other.z;
  }

  double get magnitude {
    return sqrt(x * x + y * y + z * z);
  }

  OrientationVector normalize() {
    final length = magnitude;

    if (length == 0) {
      return const OrientationVector(
        x: 0,
        y: 0,
        z: 0,
      );
    }

    return OrientationVector(
      x: x / length,
      y: y / length,
      z: z / length,
    );
  }

  OrientationVector cross(OrientationVector other) {
    return OrientationVector(
      x: y * other.z - z * other.y,
      y: z * other.x - x * other.z,
      z: x * other.y - y * other.x,
    );
  }
}

class DeviceOrientation {
  final OrientationVector right;
  final OrientationVector forward;
  final OrientationVector up;

  const DeviceOrientation({
    required this.right,
    required this.forward,
    required this.up,
  });
}

class OrientationService {
  DeviceOrientation? calculateOrientation(SensorData data) {
    final gravity = OrientationVector(
      x: data.accelerometerX,
      y: data.accelerometerY,
      z: data.accelerometerZ,
    ).normalize();

    final magnetic = OrientationVector(
      x: data.magnetometerX,
      y: data.magnetometerY,
      z: data.magnetometerZ,
    );

    if (gravity.magnitude == 0 || magnetic.magnitude == 0) {
      return null;
    }

    final magneticNormalized = magnetic.normalize();

    // Horizontal direction perpendicular to gravity.
    final north = OrientationVector(
      x: magneticNormalized.x,
      y: magneticNormalized.y,
      z: magneticNormalized.z,
    );

    final east = gravity.cross(north).normalize();

    final correctedNorth = east.cross(gravity).normalize();

    return DeviceOrientation(
      right: east,
      forward: correctedNorth,
      up: gravity,
    );
  }
}