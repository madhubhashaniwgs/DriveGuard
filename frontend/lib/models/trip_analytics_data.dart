
import 'trip_history_data.dart';

class TripAnalyticsData {
  final int totalTrips;
  final int totalDrivingTimeSeconds;
  final double totalDistanceKm;
  final double averageSpeedKmh;
  final double maxSpeedKmh;
  final int totalEvents;
  final int smoothTrips;
  final int tripsWithEvents;
  final Map<String, int> eventBreakdown;
  final List<TripHistoryData> recentTrips;

  const TripAnalyticsData({
    required this.totalTrips,
    required this.totalDrivingTimeSeconds,
    required this.totalDistanceKm,
    required this.averageSpeedKmh,
    required this.maxSpeedKmh,
    required this.totalEvents,
    required this.smoothTrips,
    required this.tripsWithEvents,
    required this.eventBreakdown,
    required this.recentTrips,
  });

  factory TripAnalyticsData.fromJson(Map<String, dynamic> json) {
    return TripAnalyticsData(
      totalTrips: (json['total_trips'] as num?)?.toInt() ?? 0,
      totalDrivingTimeSeconds:
          (json['total_driving_time_seconds'] as num?)?.toInt() ?? 0,
      totalDistanceKm:
          (json['total_distance_km'] as num?)?.toDouble() ?? 0.0,
      averageSpeedKmh:
          (json['average_speed_kmh'] as num?)?.toDouble() ?? 0.0,
      maxSpeedKmh:
          (json['max_speed_kmh'] as num?)?.toDouble() ?? 0.0,
      totalEvents: (json['total_events'] as num?)?.toInt() ?? 0,
      smoothTrips: (json['smooth_trips'] as num?)?.toInt() ?? 0,
      tripsWithEvents: (json['trips_with_events'] as num?)?.toInt() ?? 0,
      eventBreakdown: Map<String, int>.from(
        (json['event_breakdown'] as Map?)?.map(
              (key, value) => MapEntry(
                key.toString(),
                (value as num).toInt(),
              ),
            ) ??
            {},
      ),
      recentTrips: (json['recent_trips'] as List<dynamic>? ?? [])
          .map(
            (trip) => TripHistoryData.fromJson(
              trip as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Duration get totalDrivingTime =>
      Duration(seconds: totalDrivingTimeSeconds);
}
