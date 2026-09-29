import 'package:flutter/material.dart';

import '../services/motion_calibration_service.dart';

class CalibrationScreen extends StatefulWidget {
  final MotionCalibrationService calibrationService;

  const CalibrationScreen({
    super.key,
    required this.calibrationService,
  });

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  bool _calibrated = false;

  void _calibrate() {
    widget.calibrationService.calibratePhoneTopAsForward();

    setState(() {
      _calibrated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Calibration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.phone_android,
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'Place your phone in the vehicle mount.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Make sure the top of the phone points '
              'towards the front of the vehicle.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'Keep the vehicle stationary while calibrating.',
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            if (_calibrated)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Calibration completed.',
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              onPressed: _calibrate,
              child: const Text('Calibrate'),
            ),
          ],
        ),
      ),
    );
  }
}