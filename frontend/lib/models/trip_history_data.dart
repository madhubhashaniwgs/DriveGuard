
class TripHistoryData {
  final String tripId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  final String overallStatus;
  final int eventCount;

  const TripHistoryData({
    required this.tripId,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    required this.overallStatus,
    required this.eventCount,
  });

  factory TripHistoryData.fromJson(Map<String, dynamic> json) {
    return TripHistoryData(
      tripId: json['trip_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      durationSeconds: json['duration_seconds'] as int,
      overallStatus: json['overall_status'] as String,
      eventCount: json['event_count'] as int,
    );
  }

  Duration get duration => Duration(seconds: durationSeconds);
}
