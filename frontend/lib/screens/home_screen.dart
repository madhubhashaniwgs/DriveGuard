
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../models/trip_analytics_data.dart';
import 'active_trip_screen.dart';
import 'trip_history_screen.dart';
import 'trip_analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const Color primaryOrange = Color(0xFFFF9800);

  final List<Widget> _screens = const [
    _HomeTab(),
    TripHistoryScreen(),
    TripAnalyticsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: primaryOrange,
        unselectedItemColor: const Color(0xFF999999),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart_rounded),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}

// Home tab content
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  TripAnalyticsData? _analytics;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  // Fetch analytics data from the backend.
  Future<void> _loadAnalytics() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
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
              result['message'] ?? 'Failed to load analytics';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Unable to load dashboard data. Please try again.';
        _isLoading = false;
      });
    }
  }

  String _formatDrivingTime(int seconds) {
    final duration = Duration(seconds: seconds);

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }

    return '${duration.inMinutes} min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DriveGuard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF212121),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadAnalytics,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh dashboard',
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFF8E1),
        child: RefreshIndicator(
          color: const Color(0xFFFF9800),
          onRefresh: _loadAnalytics,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Smart Driving Monitor',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                ),

                const SizedBox(height: 20),

                // Ready to Drive Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.directions_car,
                        size: 55,
                        color: Colors.white,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Ready to Drive',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Start a trip to monitor your driving',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Driving Overview
                const Text(
                  'Driving Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),

                const SizedBox(height: 15),

                // Statistics - First Row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Trips',
                        value: _isLoading
                            ? '...'
                            : _analytics?.totalTrips.toString() ?? '—',
                        icon: Icons.route_rounded,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _StatCard(
                        title: 'Total Distance',
                        value: _isLoading
                            ? '...'
                            : '${(_analytics?.totalDistanceKm ?? 0).toStringAsFixed(2)} km',
                        icon: Icons.map_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Statistics - Second Row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Driving Events',
                        value: _isLoading
                            ? '...'
                            : _analytics?.totalEvents.toString() ?? '—',
                        icon: Icons.warning_amber_rounded,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _StatCard(
                        title: 'Total Driving Time',
                        value: _isLoading
                            ? '...'
                            : _analytics != null
                                ? _formatDrivingTime(
                                    _analytics!.totalDrivingTimeSeconds,
                                  )
                                : '—',
                        icon: Icons.access_time_rounded,
                      ),
                    ),
                  ],
                ),

                // Loading indicator
                if (_isLoading && _analytics == null) ...[
                  const SizedBox(height: 20),
                  const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF9800),
                    ),
                  ),
                ],

                // Error message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        TextButton.icon(
                          onPressed: _loadAnalytics,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                // Start Trip Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                   onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActiveTripScreen(
                            onTripCompleted: _loadAnalytics,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      'START TRIP',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
        children: [
          Icon(
            icon,
            color: const Color(0xFFFF9800),
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
