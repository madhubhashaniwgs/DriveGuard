import '../models/sensor_data.dart';

class SensorDataRecorder {
  final List<SensorData> _recordedData = [];

  bool _isRecording = false;

  List<SensorData> get recordedData => List.unmodifiable(_recordedData);

  bool get isRecording => _isRecording;

  void startRecording() {
    _recordedData.clear();
    _isRecording = true;
  }

  void record(SensorData data) {
    if (!_isRecording) return;

    _recordedData.add(data);
  }

  void stopRecording() {
    _isRecording = false;
  }

  void clear() {
    _recordedData.clear();
  }

  int get dataCount => _recordedData.length;
}