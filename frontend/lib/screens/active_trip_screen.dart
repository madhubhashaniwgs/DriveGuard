import 'dart:async';

import 'package:flutter/material.dart';
import 'trip_summary_screen.dart';
import '../models/driving_event_data.dart';
import '../models/sensor_data.dart';
import '../services/driving_event_detector.dart';
import '../services/gravity_estimator.dart';
import '../services/motion_calibration_service.dart';
import '../services/sensor_data_recorder.dart';
import '../services/sensor_filter.dart';
import '../services/sensor_metrics_service.dart';
import '../services/sensor_service.dart';

class ActiveTripScreen extends StatefulWidget {
  const ActiveTripScreen({super.key});

  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  final SensorService _sensorService = SensorService();
  final SensorDataRecorder _sensorDataRecorder = SensorDataRecorder();
  final SensorFilter _sensorFilter = SensorFilter();
  final GravityEstimator _gravityEstimator = GravityEstimator();
  final SensorMetricsService _metricsService = SensorMetricsService();

  final MotionCalibrationService _motionCalibrationService =
      MotionCalibrationService();

  final DrivingEventDetector _drivingEventDetector =
      DrivingEventDetector();

  DrivingEventData? _lastDrivingEvent;

  StreamSubscription<SensorData>? _sensorDataSubscription;
  Timer? _timer;

  DateTime? _tripStartTime;

  Duration _tripDuration = Duration.zero;

  bool _isTripActive = true;

  @override
  void initState() {
    super.initState();

    _startSensors();
    _startTimer();
  }

  void _startSensors() {
    _sensorFilter.reset();
    _gravityEstimator.reset();
    _drivingEventDetector.reset();

    _sensorDataRecorder.startRecording();

    _tripStartTime = DateTime.now();

    if (!_motionCalibrationService.isCalibrated) {
      _motionCalibrationService.calibratePhoneTopAsForward();
    }

    _sensorService.start();

    _sensorDataSubscription =
        _sensorService.sensorDataStream.listen((SensorData rawData) {
      if (!mounted || !_isTripActive) return;

      // 1. Record raw sensor data.
      _sensorDataRecorder.record(rawData);

      // 2. Filter sensor data.
      final filteredData = _sensorFilter.filter(rawData);

      // 3. Remove gravity.
      final linearAccelerationData =
          _gravityEstimator.removeGravity(filteredData);

      // 4. Calculate sensor metrics.
      final metrics = _metricsService.calculate(
        totalAccelerationData: filteredData,
        linearAccelerationData: linearAccelerationData,
      );

      // 5. Calculate longitudinal acceleration.
      final longitudinalAcceleration =
          _motionCalibrationService.calculateLongitudinalAcceleration(
        accelerationX: linearAccelerationData.accelerometerX,
        accelerationY: linearAccelerationData.accelerometerY,
        accelerationZ: linearAccelerationData.accelerometerZ,
      );

      // 6. Current MVP lateral axis.
      final lateralAcceleration =
          linearAccelerationData.accelerometerX;

      // 7. Detect driving event.
      final drivingEvent = _drivingEventDetector.detect(
        timestamp: rawData.timestamp,
        longitudinalAcceleration: longitudinalAcceleration,
        lateralAcceleration: lateralAcceleration,
      );

      // 8. Save only meaningful events.
      if (drivingEvent.type.name != 'normal') {
        _sensorDataRecorder.recordDrivingEvent(drivingEvent);
      }

      if (!mounted) return;

      setState(() {
        if (drivingEvent.type.name != 'normal') {
          _lastDrivingEvent = drivingEvent;
        }
      });

      // Debug information stays in terminal only.
      debugPrint(
        'Total: '
        '${metrics.accelerationMagnitude.toStringAsFixed(2)} m/s² | '
        'Linear: '
        '${metrics.linearAccelerationMagnitude.toStringAsFixed(2)} m/s² | '
        'Longitudinal: '
        '${longitudinalAcceleration.toStringAsFixed(2)} m/s² | '
        'Lateral: '
        '${lateralAcceleration.toStringAsFixed(2)} m/s² | '
        'Angular: '
        '${metrics.angularVelocityMagnitude.toStringAsFixed(2)} rad/s | '
        'Event: ${drivingEvent.type.name}',
      );
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted || !_isTripActive || _tripStartTime == null) {
          return;
        }

        setState(() {
          _tripDuration =
              DateTime.now().difference(_tripStartTime!);
        });
      },
    );
  }

  void _stopTrip() {
    _timer?.cancel();
    _timer = null;

    _sensorDataSubscription?.cancel();
    _sensorDataSubscription = null;

    _sensorService.stop();

    _isTripActive = false;

    final completedTrip = _sensorDataRecorder.stopRecording();

    if (completedTrip != null) {
      debugPrint('Trip ID: ${completedTrip.tripId}');
      debugPrint('Start time: ${completedTrip.startTime}');
      debugPrint('End time: ${completedTrip.endTime}');
      debugPrint('Duration: ${completedTrip.duration}');
      debugPrint('Sensor records: ${completedTrip.sensorDataCount}');
      debugPrint(
        'Driving events: ${completedTrip.drivingEvents.length}',
      );
    }

    if (mounted && completedTrip != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TripSummaryScreen(
            trip: completedTrip,
          ),
        ),
      );
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

  String _getDrivingStatus() {
    if (_lastDrivingEvent == null) {
      return 'Smooth Driving';
    }

    switch (_lastDrivingEvent!.type.name) {
      case 'suddenAcceleration':
        return 'Sudden Acceleration';

      case 'suddenBraking':
        return 'Sudden Braking';

      case 'harshTurn':
        return 'Harsh Turn';

      default:
        return 'Smooth Driving';
    }
  }

  String _getDrivingMessage() {
    if (_lastDrivingEvent == null) {
      return 'No unusual driving events detected';
    }

    switch (_lastDrivingEvent!.type.name) {
      case 'suddenAcceleration':
        return 'Drive smoothly and avoid rapid acceleration.';

      case 'suddenBraking':
        return 'Keep a safe following distance and brake smoothly.';

      case 'harshTurn':
        return 'Take turns smoothly and maintain safe control.';

      default:
        return 'No unusual driving events detected';
    }
  }

  IconData _getStatusIcon() {
    if (_lastDrivingEvent == null) {
      return Icons.check_circle_rounded;
    }

    switch (_lastDrivingEvent!.type.name) {
      case 'suddenAcceleration':
        return Icons.speed_rounded;

      case 'suddenBraking':
        return Icons.warning_rounded;

      case 'harshTurn':
        return Icons.turn_right_rounded;

      default:
        return Icons.check_circle_rounded;
    }
  }

  Color _getStatusColor() {
    if (_lastDrivingEvent == null) {
      return const Color(0xFF4CAF50);
    }

    return const Color(0xFFFF9800);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sensorDataSubscription?.cancel();
    _sensorService.dispose();
    _sensorDataRecorder.stopRecording();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventCount = _sensorDataRecorder.eventCount;
    

    final statusColor = _getStatusColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Active Trip',
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Trip Active Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.directions_car_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Trip Active',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'DriveGuard is monitoring your trip',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _formatDuration(_tripDuration),
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Trip Duration',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Current Driving Status
                _StatusCard(
                  icon: _getStatusIcon(),
                  title: _getDrivingStatus(),
                  message: _getDrivingMessage(),
                  color: statusColor,
                ),

                const SizedBox(height: 20),

               
               // Trip Statistics
                _InfoCard(
                  icon: Icons.warning_amber_rounded,
                  title: 'Driving Events Detected',
                  value: eventCount.toString(),
                ),

                const SizedBox(height: 12),

                _LatestEventCard(
                  event: _lastDrivingEvent,
                ),

                const SizedBox(height: 30),

                // Stop Trip
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton.icon(
                    onPressed: _stopTrip,
                    icon: const Icon(
                      Icons.stop_circle_outlined,
                      size: 24,
                    ),
                    label: const Text(
                      'END TRIP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'DriveGuard is analyzing your driving in the background.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const _StatusCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 38,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Driving Status',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF777777),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFF9800),
              size: 26,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }
}

class _LatestEventCard extends StatelessWidget {
  final DrivingEventData? event;

  const _LatestEventCard({
    required this.event,
  });

  String _eventTitle() {
    if (event == null) {
      return 'No Events Yet';
    }

    switch (event!.type.name) {
      case 'suddenAcceleration':
        return 'Sudden Acceleration';

      case 'suddenBraking':
        return 'Sudden Braking';

      case 'harshTurn':
        return 'Harsh Turn';

      default:
        return 'No Events Yet';
    }
  }

  String _eventMessage() {
    if (event == null) {
      return 'Your driving looks smooth so far.';
    }

    switch (event!.type.name) {
      case 'suddenAcceleration':
        return 'Rapid acceleration detected during the trip.';

      case 'suddenBraking':
        return 'Rapid braking detected during the trip.';

      case 'harshTurn':
        return 'A sharp turning movement was detected.';

      default:
        return 'Your driving looks smooth so far.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasEvent = event != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasEvent
              ? const Color(0xFFFFCC80)
              : const Color(0xFFE8E8E8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasEvent
                  ? const Color(0xFFFFF3E0)
                  : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              hasEvent
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline_rounded,
              color: hasEvent
                  ? const Color(0xFFFF9800)
                  : const Color(0xFF4CAF50),
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _eventTitle(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _eventMessage(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                    height: 1.4,
                  ),
                ),
                if (event != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(event!.timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');

    return '$hour:$minute:$second';
  }
}