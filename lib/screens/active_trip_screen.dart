
import 'dart:async';

import 'package:flutter/material.dart';

import '../services/sensor_service.dart';

class ActiveTripScreen extends StatefulWidget {
  const ActiveTripScreen({super.key});

  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  final SensorService _sensorService = SensorService();

  StreamSubscription<SensorData>? _accelerometerSubscription;
  StreamSubscription<SensorData>? _gyroscopeSubscription;

  // Accelerometer values
  double _accX = 0;
  double _accY = 0;
  double _accZ = 0;

  // Gyroscope values
  double _gyroX = 0;
  double _gyroY = 0;
  double _gyroZ = 0;

  @override
  void initState() {
    super.initState();

    _startSensors();
  }

  void _startSensors() {
    _sensorService.startSensors();

    // Listen to accelerometer data
    _accelerometerSubscription =
        _sensorService.accelerometerStream.listen((SensorData data) {
      if (!mounted) return;

      setState(() {
        _accX = data.x;
        _accY = data.y;
        _accZ = data.z;
      });
    });

    // Listen to gyroscope data
    _gyroscopeSubscription =
        _sensorService.gyroscopeStream.listen((SensorData data) {
      if (!mounted) return;

      setState(() {
        _gyroX = data.x;
        _gyroY = data.y;
        _gyroZ = data.z;
      });
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();

    _sensorService.dispose();

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
              // ------------------------------------------------------------
              // TRIP STATUS
              // ------------------------------------------------------------
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

              // ------------------------------------------------------------
              // ACCELEROMETER SECTION
              // ------------------------------------------------------------
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

              // Accelerometer X
              _SensorCard(
                title: 'X Axis',
                value: _accX.toStringAsFixed(2),
                unit: 'm/s²',
                icon: Icons.swap_horiz,
              ),

              const SizedBox(height: 15),

              // Accelerometer Y
              _SensorCard(
                title: 'Y Axis',
                value: _accY.toStringAsFixed(2),
                unit: 'm/s²',
                icon: Icons.swap_vert,
              ),

              const SizedBox(height: 15),

              // Accelerometer Z
              _SensorCard(
                title: 'Z Axis',
                value: _accZ.toStringAsFixed(2),
                unit: 'm/s²',
                icon: Icons.height,
              ),

              const SizedBox(height: 30),

              // ------------------------------------------------------------
              // GYROSCOPE SECTION
              // ------------------------------------------------------------
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

              // Gyroscope X
              _SensorCard(
                title: 'Gyro X',
                value: _gyroX.toStringAsFixed(2),
                unit: 'rad/s',
                icon: Icons.rotate_90_degrees_ccw,
              ),

              const SizedBox(height: 15),

              // Gyroscope Y
              _SensorCard(
                title: 'Gyro Y',
                value: _gyroY.toStringAsFixed(2),
                unit: 'rad/s',
                icon: Icons.rotate_90_degrees_cw,
              ),

              const SizedBox(height: 15),

              // Gyroscope Z
              _SensorCard(
                title: 'Gyro Z',
                value: _gyroZ.toStringAsFixed(2),
                unit: 'rad/s',
                icon: Icons.sync,
              ),

              const SizedBox(height: 30),

              // ------------------------------------------------------------
              // STOP TRIP BUTTON
              // ------------------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
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

// ==========================================================================
// SENSOR CARD
// ==========================================================================

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

