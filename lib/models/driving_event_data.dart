import 'driving_event.dart';

class DrivingEventData {
  final DrivingEventType type;
  final DateTime timestamp;
  final double value;

  const DrivingEventData({
    required this.type,
    required this.timestamp,
    required this.value,
  });
}