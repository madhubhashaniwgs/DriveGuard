
import 'package:flutter/material.dart';

import '../models/trip_history_data.dart';
import '../services/api_service.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
 

  List<TripHistoryData> _trips = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ApiService.getTrips();

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _trips = result['data'] as List<TripHistoryData>;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage =
            result['message'] ?? 'Failed to load trip history.';
        _isLoading = false;
      });
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trip History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF212121),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadTrips,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFF8E1),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF9800),
                  ),
                )
              : _errorMessage != null
                  ? _ErrorHistory(
                      message: _errorMessage!,
                      onRetry: _loadTrips,
                    )
                  : _trips.isEmpty
                      ? const _EmptyHistory()
                      : RefreshIndicator(
                          color: const Color(0xFFFF9800),
                          onRefresh: _loadTrips,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: _trips.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final trip = _trips[index];

                              return _TripHistoryCard(
                                trip: trip,
                                date: _formatDate(trip.startTime),
                                duration:
                                    _formatDuration(trip.duration),
                              );
                            },
                          ),
                        ),
        ),
      ),
    );
  }
}

class _TripHistoryCard extends StatelessWidget {
  final TripHistoryData trip;
  final String date;
  final String duration;

  const _TripHistoryCard({
    required this.trip,
    required this.date,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final eventCount = trip.eventCount;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: eventCount == 0
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.directions_car_rounded,
              color: eventCount == 0
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFFF9800),
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: Color(0xFF777777),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      duration,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.warning_amber_outlined,
                      size: 16,
                      color: Color(0xFF777777),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$eventCount events',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  trip.overallStatus,
                  style: TextStyle(
                    fontSize: 12,
                    color: eventCount == 0
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFE68A00),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorHistory extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorHistory({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
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
              'Unable to Load Trips',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF777777),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
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
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3E0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 52,
                color: Color(0xFFFF9800),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Trips Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your completed trips will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF777777),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
