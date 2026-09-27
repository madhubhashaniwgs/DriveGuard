import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  void startAccelerometer() {
    _accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        print(
          'Accelerometer → '
          'X: ${event.x.toStringAsFixed(2)}, '
          'Y: ${event.y.toStringAsFixed(2)}, '
          'Z: ${event.z.toStringAsFixed(2)}',
        );
      },
    );
  }

  void stopAccelerometer() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }
}