
import 'driving_event_data.dart';
import 'sensor_data.dart';

class TripData {
  final String tripId;
  final DateTime startTime;

  DateTime? endTime;

  final List<SensorData> sensorData;
  final List<DrivingEventData> drivingEvents;

  // GPS trip metrics
  double distanceMeters;
  double maxSpeedKmh;

  TripData({
    required this.tripId,
    required this.startTime,
    this.endTime,
    List<SensorData>? sensorData,
    List<DrivingEventData>? drivingEvents,
    this.distanceMeters = 0.0,
    this.maxSpeedKmh = 0.0,
  })  : sensorData = sensorData ?? [],
        drivingEvents = drivingEvents ?? [];

  bool get isCompleted => endTime != null;

  Duration? get duration {
    if (endTime == null) return null;

    return endTime!.difference(startTime);
  }

  int get sensorDataCount => sensorData.length;

  int get drivingEventCount => drivingEvents.length;

  double get distanceKm => distanceMeters / 1000;

  double get averageSpeedKmh {
    final tripDuration = duration;

    if (tripDuration == null || tripDuration.inSeconds <= 0) {
      return 0.0;
    }

    return distanceKm / (tripDuration.inSeconds / 3600);
  }

  // Convert completed trip into JSON for the backend.
  Map<String, dynamic> toJson() {
    if (endTime == null) {
      throw StateError('Cannot upload an incomplete trip.');
    }

    return {
      'trip_id': tripId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime!.toIso8601String(),
      'duration_seconds': duration!.inSeconds,
      'distance_km': distanceKm,
      'average_speed_kmh': averageSpeedKmh,
      'max_speed_kmh': maxSpeedKmh,
      'overall_status': drivingEvents.isEmpty
          ? 'Smooth Driving'
          : 'Driving Events Detected',
      'event_count': drivingEventCount,
    };
  }
}
