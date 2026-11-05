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

  factory DrivingEventData.fromJson(Map<String, dynamic> json) {
    return DrivingEventData(
      type: DrivingEventType.values.firstWhere(
        (eventType) => eventType.name == json['type'],
        orElse: () => DrivingEventType.normal,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      value: (json['value'] as num).toDouble(),
    );
  }
}