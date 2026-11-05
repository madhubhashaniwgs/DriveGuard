
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/trip_data.dart';
import '../models/driving_event_data.dart';
import '../models/trip_history_data.dart';

class ApiService {
  // Check backend and database connection.
  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.healthUrl))
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
        };
      }

      return {
        'success': false,
        'message': 'Server error: ${response.statusCode}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Upload a completed trip to the backend.
  static Future<Map<String, dynamic>> createTrip(
    TripData trip,
  ) async {
    try {
      final tripJson = trip.toJson();

      // Events are uploaded separately.
      tripJson['event_count'] = 0;

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/trips/'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(tripJson),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
        };
      }

      return {
        'success': false,
        'message': data['detail'] ?? 'Failed to create trip',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Upload a driving event to the backend.
  static Future<Map<String, dynamic>> uploadDrivingEvent(
    String tripId,
    DrivingEventData event,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              '${ApiConfig.baseUrl}/trips/$tripId/events',
            ),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'type': event.type.name,
              'timestamp': event.timestamp.toIso8601String(),
              'value': event.value,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
        };
      }

      return {
        'success': false,
        'message': data['detail'] ?? 'Failed to upload driving event',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  
  // Fetch all trips from the backend.
  static Future<Map<String, dynamic>> getTrips() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/trips/'),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
    final List<dynamic> tripsJson = data['trips'];

    final trips = tripsJson
        .map(
            (trip) => TripHistoryData.fromJson(
            trip as Map<String, dynamic>,
            ),
        )
        .toList();

    return {
        'success': true,
        'data': trips,
    };
    }

      return {
        'success': false,
        'message': data['detail'] ?? 'Failed to fetch trips',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

}
