import 'package:flutter/material.dart';

import '../models/trip_data.dart';
import '../models/driving_event_data.dart';
import '../services/api_service.dart';
import 'trip_summary_screen.dart';
import '../models/trip_history_data.dart';

class TripDetailsScreen extends StatefulWidget {
  final String tripId;

  const TripDetailsScreen({
    super.key,
    required this.tripId,
  });

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  TripData? _trip;
  TripHistoryData? _historyData;

  @override
  void initState() {
    super.initState();
    _loadTripDetails();
  }

  Future<void> _loadTripDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Fetch trip details and driving events from the backend.
    final results = await Future.wait([
      ApiService.getTripDetails(widget.tripId),
      ApiService.getDrivingEvents(widget.tripId),
    ]);

    if (!mounted) return;

    final tripResult = results[0];
    final eventsResult = results[1];

    if (tripResult['success'] != true) {
      setState(() {
        _errorMessage =
            tripResult['message'] ?? 'Failed to load trip details.';
        _isLoading = false;
      });
      return;
    }

    if (eventsResult['success'] != true) {
      setState(() {
        _errorMessage =
            eventsResult['message'] ?? 'Failed to load driving events.';
        _isLoading = false;
      });
      return;
    }

    try {
      final tripJson =
          tripResult['data'] as Map<String, dynamic>;
      final historyData = TripHistoryData.fromJson(tripJson);

      final events =
          eventsResult['data'] as List<DrivingEventData>;

      final trip = TripData(
        tripId: tripJson['trip_id'] as String,
        startTime: DateTime.parse(
          tripJson['start_time'] as String,
        ),
        endTime: DateTime.parse(
          tripJson['end_time'] as String,
        ),
        drivingEvents: events,
      );

     setState(() {
        _trip = trip;
        _historyData = historyData;
        _isLoading = false;
        });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to process trip details: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Trip Details'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF212121),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF9800),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Trip Details'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF212121),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  size: 55,
                  color: Color(0xFFFF9800),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unable to Load Trip Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF777777),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _loadTripDetails,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return TripSummaryScreen(
    trip: _trip!,
    historyData: _historyData!,
    );
  }
}