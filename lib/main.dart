```dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const DriveGuardApp());
}

class DriveGuardApp extends StatelessWidget {
  const DriveGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DriveGuard',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF9800),
        ),
        useMaterial3: true,
      ),

      home: const HomeScreen(),
    );
  }
}
```
