import 'sensor_data.dart';

class TripData {
  final String tripId;
  final DateTime startTime;
  DateTime? endTime;
  final List<SensorData> sensorData;

  TripData({
    required this.tripId,
    required this.startTime,
    this.endTime,
    List<SensorData>? sensorData,
  }) : sensorData = sensorData ?? [];

  bool get isCompleted => endTime != null;

  Duration? get duration {
    if (endTime == null) return null;

    return endTime!.difference(startTime);
  }

  int get sensorDataCount => sensorData.length;
}