import 'package:flutter/material.dart';

import '../models/trip_data.dart';
import 'trip_summary_screen.dart';

class TripHistoryScreen extends StatelessWidget {
  final List<TripData> trips;

  const TripHistoryScreen({
    super.key,
    this.trips = const [],
  });

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';

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
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF212121),
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFFFF8E1),
        child: SafeArea(
          child: trips.isEmpty
              ? _EmptyHistory()
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: trips.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final trip = trips[index];

                    return _TripHistoryCard(
                      trip: trip,
                      date: _formatDate(trip.startTime),
                      duration: _formatDuration(trip.duration),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TripSummaryScreen(
                              trip: trip,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _TripHistoryCard extends StatelessWidget {
  final TripData trip;
  final String date;
  final String duration;
  final VoidCallback onTap;

  const _TripHistoryCard({
    required this.trip,
    required this.date,
    required this.duration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final eventCount = trip.drivingEventCount;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF999999),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
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
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
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