import 'package:uuid/uuid.dart';

import '../models/sensor_data.dart';
import '../models/trip_data.dart';

class SensorDataRecorder {
  final Uuid _uuid = const Uuid();

  TripData? _currentTrip;

  TripData? get currentTrip => _currentTrip;

  bool get isRecording => _currentTrip != null;

  int get dataCount => _currentTrip?.sensorDataCount ?? 0;

  void startRecording() {
    if (isRecording) return;

    _currentTrip = TripData(
      tripId: _uuid.v4(),
      startTime: DateTime.now(),
    );
  }

  void record(SensorData data) {
    if (!isRecording) return;

    _currentTrip!.sensorData.add(data);
  }

  TripData? stopRecording() {
    if (!isRecording) return null;

    _currentTrip!.endTime = DateTime.now();

    final completedTrip = _currentTrip;

    _currentTrip = null;

    return completedTrip;
  }

  void clear() {
    _currentTrip = null;
  }
}