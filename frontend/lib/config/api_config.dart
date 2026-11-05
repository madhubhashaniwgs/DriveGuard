
class ApiConfig {
  // Android phone connected through USB.
  // Requires adb reverse tcp:8000 tcp:8000
  static const String baseUrl = 'http://127.0.0.1:8000';

  static const String healthEndpoint = '/health';

  static String get healthUrl => '$baseUrl$healthEndpoint';
}
