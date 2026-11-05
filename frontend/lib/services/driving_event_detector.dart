import '../models/driving_event.dart';
import '../models/driving_event_data.dart';

class DrivingEventDetector {
  final double accelerationThreshold;
  final double brakingThreshold;
  final double turnThreshold;
  final Duration eventCooldown;

  DateTime? _lastEventTime;

  DrivingEventType? _lastEventType;

  DrivingEventDetector({
    this.accelerationThreshold = 3.0,
    this.brakingThreshold = -3.0,
    this.turnThreshold = 3.5,
    this.eventCooldown = const Duration(seconds: 2),
  });

  DrivingEventData detect({
    required DateTime timestamp,
    required double longitudinalAcceleration,
    required double lateralAcceleration,
  }) {
    DrivingEventType detectedType = DrivingEventType.normal;
    double detectedValue = longitudinalAcceleration;

    if (longitudinalAcceleration >= accelerationThreshold) {
      detectedType = DrivingEventType.suddenAcceleration;
      detectedValue = longitudinalAcceleration;
    } else if (longitudinalAcceleration <= brakingThreshold) {
      detectedType = DrivingEventType.suddenBraking;
      detectedValue = longitudinalAcceleration;
    } else if (lateralAcceleration.abs() >= turnThreshold) {
      detectedType = DrivingEventType.harshTurn;
      detectedValue = lateralAcceleration;
    }

    if (detectedType == DrivingEventType.normal) {
      return DrivingEventData(
        type: DrivingEventType.normal,
        timestamp: timestamp,
        value: longitudinalAcceleration,
      );
    }

    if (_shouldIgnoreEvent(
      timestamp,
      detectedType,
    )) {
      return DrivingEventData(
        type: DrivingEventType.normal,
        timestamp: timestamp,
        value: longitudinalAcceleration,
      );
    }

    _lastEventTime = timestamp;
    _lastEventType = detectedType;

    return DrivingEventData(
      type: detectedType,
      timestamp: timestamp,
      value: detectedValue,
    );
  }

  bool _shouldIgnoreEvent(
    DateTime timestamp,
    DrivingEventType type,
  ) {
    if (_lastEventTime == null) {
      return false;
    }

    final elapsed = timestamp.difference(_lastEventTime!);

    if (elapsed < eventCooldown) {
      return true;
    }

    if (_lastEventType == type &&
        elapsed < eventCooldown) {
      return true;
    }

    return false;
  }

  void reset() {
    _lastEventTime = null;
    _lastEventType = null;
  }
}