
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/trip_analytics_data.dart';
import '../models/trip_history_data.dart';
import '../services/api_service.dart';
import 'trip_details_screen.dart';
import '../services/trip_data_refresh_service.dart';

class TripAnalyticsScreen extends StatefulWidget {
  const TripAnalyticsScreen({super.key});

  @override
  State<TripAnalyticsScreen> createState() =>
      _TripAnalyticsScreenState();
}

class _TripAnalyticsScreenState extends State<TripAnalyticsScreen> {
  TripAnalyticsData? _analytics;
  bool _isLoading = true;
  String? _errorMessage;

  static const Color primaryOrange = Color(0xFFFF9800);
  static const Color backgroundColor = Color(0xFFFFF8E1);

  @override
    void initState() {
    super.initState();

    TripDataRefreshService.refreshNotifier.addListener(
        _onTripDataChanged,
    );

    _loadAnalytics();
    }

    void _onTripDataChanged() {
    _loadAnalytics();
    }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ApiService.getTripAnalytics();

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _analytics = result['data'] as TripAnalyticsData;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage =
            result['message'] ?? 'Failed to load analytics.';
        _isLoading = false;
      });
    }
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }

    return '${minutes}m';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}';
  }

    @override
    void dispose() {
    TripDataRefreshService.refreshNotifier.removeListener(
        _onTripDataChanged,
    );

    super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Trip Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF212121),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadAnalytics,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: primaryOrange,
                ),
              )
            : _errorMessage != null
                ? _AnalyticsError(
                    message: _errorMessage!,
                    onRetry: _loadAnalytics,
                  )
                : _analytics == null
                    ? const Center(
                        child: Text('No analytics available.'),
                      )
                    : RefreshIndicator(
                        color: primaryOrange,
                        onRefresh: _loadAnalytics,
                        child: _buildDashboard(_analytics!),
                      ),
      ),
    );
  }

  Widget _buildDashboard(TripAnalyticsData analytics) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Your Driving Overview',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Insights from your completed trips.',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF777777),
          ),
        ),
        const SizedBox(height: 20),

        // Summary cards
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Total Trips',
                value: '${analytics.totalTrips}',
                icon: Icons.directions_car_rounded,
                color: primaryOrange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Driving Time',
                value: _formatDuration(
                  analytics.totalDrivingTimeSeconds,
                ),
                icon: Icons.timer_rounded,
                color: const Color(0xFF2196F3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Smooth Trips',
                value: '${analytics.smoothTrips}',
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Total Events',
                value: '${analytics.totalEvents}',
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFE68A00),
              ),
            ),
          ],
        ),

        
        // Distance and speed metrics
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Total Distance',
                value: '${analytics.totalDistanceKm.toStringAsFixed(2)} km',
                icon: Icons.route_rounded,
                color: const Color(0xFF009688),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Average Speed',
                value: '${analytics.averageSpeedKmh.toStringAsFixed(1)} km/h',
                icon: Icons.speed_rounded,
                color: const Color(0xFF2196F3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _SummaryCard(
            title: 'Maximum Speed',
            value: '${analytics.maxSpeedKmh.toStringAsFixed(1)} km/h',
            icon: Icons.speed_rounded,
            color: const Color(0xFFE68A00),
          ),
        ),


        const SizedBox(height: 25),

        // Event breakdown
        _DashboardSection(
          title: 'Driving Event Breakdown',
          subtitle: 'Detected events across your trips',
          child: _buildEventChart(analytics),
        ),

        const SizedBox(height: 25),

        // Recent trips
        _DashboardSection(
          title: 'Recent Trips',
          subtitle: 'Your latest completed trips',
          child: analytics.recentTrips.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 25),
                  child: Center(
                    child: Text(
                      'No recent trips available.',
                      style: TextStyle(color: Color(0xFF777777)),
                    ),
                  ),
                )
              : Column(
                  children: analytics.recentTrips.map((trip) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RecentTripCard(
                        trip: trip,
                        date: _formatDate(trip.startTime),
                        duration: _formatDuration(
                          trip.durationSeconds,
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildEventChart(TripAnalyticsData analytics) {
    final breakdown = analytics.eventBreakdown;

    final events = [
      _EventChartItem(
        label: 'Acceleration',
        value: breakdown['suddenAcceleration'] ?? 0,
        color: const Color(0xFFFF9800),
      ),
      _EventChartItem(
        label: 'Braking',
        value: breakdown['suddenBraking'] ?? 0,
        color: const Color(0xFFE53935),
      ),
      _EventChartItem(
        label: 'Harsh Turn',
        value: breakdown['harshTurn'] ?? 0,
        color: const Color(0xFF2196F3),
      ),
    ];

    final maxValue = events.fold<int>(
      0,
      (maximum, event) =>
          event.value > maximum ? event.value : maximum,
    );

    final chartMaxY = maxValue == 0 ? 5.0 : (maxValue + 2).toDouble();

    return Column(
      children: [
        SizedBox(
          height: 230,
          child: BarChart(
            BarChartData(
              maxY: chartMaxY,
              alignment: BarChartAlignment.spaceAround,
              barTouchData: BarTouchData(enabled: true),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF777777),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();

                      if (index < 0 || index >= events.length) {
                        return const SizedBox.shrink();
                      }

                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          events[index].label,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF666666),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(events.length, (index) {
                final event = events[index];

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: event.value.toDouble(),
                      color: event.color,
                      width: 28,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...events.map(
          (event) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: event.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    event.label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF555555),
                    ),
                  ),
                ),
                Text(
                  '${event.value}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 27),
          const SizedBox(height: 13),
          Text(
            value,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _DashboardSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF777777),
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _EventChartItem {
  final String label;
  final int value;
  final Color color;

  const _EventChartItem({
    required this.label,
    required this.value,
    required this.color,
  });
}

class _RecentTripCard extends StatelessWidget {
  final TripHistoryData trip;
  final String date;
  final String duration;

  const _RecentTripCard({
    required this.trip,
    required this.date,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final hasEvents = trip.eventCount > 0;

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TripDetailsScreen(
              tripId: trip.tripId,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: hasEvents
                    ? const Color(0xFFFFF3E0)
                    : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.directions_car_rounded,
                color: hasEvents
                    ? const Color(0xFFFF9800)
                    : const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$duration  •  ${trip.eventCount} events',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF777777),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    trip.overallStatus,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: hasEvents
                          ? const Color(0xFFE68A00)
                          : const Color(0xFF4CAF50),
                    ),
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

class _AnalyticsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _AnalyticsError({
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
              'Unable to Load Analytics',
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
