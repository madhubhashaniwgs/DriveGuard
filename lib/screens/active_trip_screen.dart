import 'dart:async';

import 'package:flutter/material.dart';

import '../models/sensor_data.dart';
import '../services/gravity_estimator.dart';
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

  StreamSubscription<SensorData>? _sensorDataSubscription;

  // Accelerometer values
  double _accX = 0;
  double _accY = 0;
  double _accZ = 0;

  // Gyroscope values
  double _gyroX = 0;
  double _gyroY = 0;
  double _gyroZ = 0;

  // Calculated metrics
  double _totalAcceleration = 0;
  double _linearAcceleration = 0;
  double _angularVelocity = 0;

  @override
  void initState() {
    super.initState();

    _startSensors();
  }

  void _startSensors() {
    _sensorFilter.reset();
    _gravityEstimator.reset();
    _sensorDataRecorder.startRecording();

    _sensorService.start();

    _sensorDataSubscription =
        _sensorService.sensorDataStream.listen((SensorData rawData) {
      if (!mounted) return;

      // 1. Store original raw sensor data
      _sensorDataRecorder.record(rawData);

      // 2. Smooth noisy sensor values
      final filteredData = _sensorFilter.filter(rawData);

      // 3. Remove gravity
      final linearAccelerationData =
          _gravityEstimator.removeGravity(filteredData);

      // 4. Calculate metrics
      final metrics = _metricsService.calculate(
        totalAccelerationData: filteredData,
        linearAccelerationData: linearAccelerationData,
      );

      // 5. Update UI
      setState(() {
        _accX = filteredData.accelerometerX;
        _accY = filteredData.accelerometerY;
        _accZ = filteredData.accelerometerZ;

        _gyroX = filteredData.gyroscopeX;
        _gyroY = filteredData.gyroscopeY;
        _gyroZ = filteredData.gyroscopeZ;

        _totalAcceleration = metrics.accelerationMagnitude;
        _linearAcceleration = metrics.linearAccelerationMagnitude;
        _angularVelocity = metrics.angularVelocityMagnitude;
      });

      // 6. Debug output
      debugPrint(
        'Total acceleration: '
        '${metrics.accelerationMagnitude.toStringAsFixed(2)} m/s² | '
        'Linear acceleration: '
        '${metrics.linearAccelerationMagnitude.toStringAsFixed(2)} m/s² | '
        'Angular velocity: '
        '${metrics.angularVelocityMagnitude.toStringAsFixed(2)} rad/s',
      );
    });
  }

  void _stopTrip() {
    // Stop receiving sensor data
    _sensorDataSubscription?.cancel();
    _sensorDataSubscription = null;

    // Stop sensor streams
    _sensorService.stop();

    // Complete current trip
    final completedTrip = _sensorDataRecorder.stopRecording();

    if (completedTrip != null) {
      debugPrint('Trip ID: ${completedTrip.tripId}');
      debugPrint('Start time: ${completedTrip.startTime}');
      debugPrint('End time: ${completedTrip.endTime}');
      debugPrint('Duration: ${completedTrip.duration}');
      debugPrint('Sensor records: ${completedTrip.sensorDataCount}');
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _sensorDataSubscription?.cancel();
    _sensorService.dispose();
    _sensorDataRecorder.stopRecording();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Trip Status
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
                      'Trip in Progress',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Metrics Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Driving Metrics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              _SensorCard(
                title: 'Total Acceleration',
                value: _totalAcceleration.toStringAsFixed(2),
                unit: 'm/s²',
                icon: Icons.speed,
              ),

              const SizedBox(height: 15),

              _SensorCard(
                title: 'Linear Acceleration',
                value: _linearAcceleration.toStringAsFixed(2),
                unit: 'm/s²',
                icon: Icons.trending_up,
              ),

              const SizedBox(height: 15),

              _SensorCard(
                title: 'Angular Velocity',
                value: _angularVelocity.toStringAsFixed(2),
                unit: 'rad/s',
                icon: Icons.screen_rotation,
              ),

              const SizedBox(height: 30),

              // Accelerometer Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Accelerometer',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              _SensorCard(
                title: 'X Axis',
                value: _accX.toStringAsFixed(2),
                unit: 'm/s²',
                icon: Icons.swap_horiz,
              ),

              const SizedBox(height: 15),

              _SensorCard(
                title: 'Y Axis',
                value: _accY.toStringAsFixed(2),
                unit: 'm/s²',
                icon: Icons.swap_vert,
              ),

              const SizedBox(height: 15),

              _SensorCard(
                title: 'Z Axis',
                value: _accZ.toStringAsFixed(2),
                unit: 'm/s²',
                icon: Icons.height,
              ),

              const SizedBox(height: 30),

              // Gyroscope Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Gyroscope',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              _SensorCard(
                title: 'Gyro X',
                value: _gyroX.toStringAsFixed(2),
                unit: 'rad/s',
                icon: Icons.rotate_90_degrees_ccw,
              ),

              const SizedBox(height: 15),

              _SensorCard(
                title: 'Gyro Y',
                value: _gyroY.toStringAsFixed(2),
                unit: 'rad/s',
                icon: Icons.rotate_90_degrees_cw,
              ),

              const SizedBox(height: 15),

              _SensorCard(
                title: 'Gyro Z',
                value: _gyroZ.toStringAsFixed(2),
                unit: 'rad/s',
                icon: Icons.sync,
              ),

              const SizedBox(height: 30),

              // Stop Trip
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _stopTrip,
                  icon: const Icon(Icons.stop),
                  label: const Text(
                    'STOP TRIP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;

  const _SensorCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFF9800),
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      unit,
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
        ],
      ),
    );
  }
}