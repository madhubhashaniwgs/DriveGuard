import 'driving_event_data.dart';
import 'sensor_data.dart';

class TripData {
  final String tripId;
  final DateTime startTime;

  DateTime? endTime;

  final List<SensorData> sensorData;
  final List<DrivingEventData> drivingEvents;

  TripData({
    required this.tripId,
    required this.startTime,
    this.endTime,
    List<SensorData>? sensorData,
    List<DrivingEventData>? drivingEvents,
  })  : sensorData = sensorData ?? [],
        drivingEvents = drivingEvents ?? [];

  bool get isCompleted => endTime != null;

  Duration? get duration {
    if (endTime == null) return null;

    return endTime!.difference(startTime);
  }

  int get sensorDataCount => sensorData.length;

  int get drivingEventCount => drivingEvents.length;
}