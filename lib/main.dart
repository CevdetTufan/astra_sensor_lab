import 'package:astro_sensor_lab/ui/sensor_dashboard_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Astra Sensor Lab',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SensorDashboardPage(),
    );
  }
}
