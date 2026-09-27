import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../services/sensor_service.dart';

class ActiveTripScreen extends StatefulWidget {
  const ActiveTripScreen({super.key});

  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  final SensorService _sensorService = SensorService();

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  double _x = 0;
  double _y = 0;
  double _z = 0;

  @override
  void initState() {
    super.initState();

    _startAccelerometer();
  }

  void _startAccelerometer() {
    _accelerometerSubscription =
        accelerometerEventStream().listen((AccelerometerEvent event) {
      if (!mounted) return;

      setState(() {
        _x = event.x;
        _y = event.y;
        _z = event.z;
      });
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _sensorService.stopAccelerometer();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Active Trip',
          style: TextStyle(fontWeight: FontWeight.bold),
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

              const SizedBox(height: 20),

              // Accelerometer X
              _SensorCard(
                title: 'X Axis',
                value: _x.toStringAsFixed(2),
                unit: 'm/s²',
                icon: Icons.swap_horiz,
              ),

              const SizedBox(height: 15),

              // Accelerometer Y
              _SensorCard(
                title: 'Y Axis',
                value: _y.toStringAsFixed(2),
                unit: 'm/s²',
                icon: Icons.swap_vert,
              ),

              const SizedBox(height: 15),

              // Accelerometer Z
              _SensorCard(
                title: 'Z Axis',
                value: _z.toStringAsFixed(2),
                unit: 'm/s²',
                icon: Icons.height,
              ),

              const SizedBox(height: 25),

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
                  ),
                ),
                const SizedBox(height: 5),
                Row(
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

