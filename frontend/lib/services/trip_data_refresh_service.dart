
import 'package:flutter/foundation.dart';

class TripDataRefreshService {
  static final ValueNotifier<int> refreshNotifier = ValueNotifier<int>(0);

  static void notifyTripDataChanged() {
    refreshNotifier.value++;
  }
}
