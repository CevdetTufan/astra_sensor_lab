import 'dart:async';

import 'package:astro_sensor_lab/sensors/sensor_types.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorDashboardPage extends StatefulWidget {
  const SensorDashboardPage({super.key});

  @override
  State<SensorDashboardPage> createState() => _SensorDashboardPageState();
}

class _SensorDashboardPageState extends State<SensorDashboardPage> {
  List<double> _accelerometerValues = [0, 0, 0];
  List<double> _gyroscopeValues = [0, 0, 0];
  List<double> _magnetometerValues = [0, 0, 0];

  // Sensörlerin anlık kullanılabilirlik durumu
  SensorAvailability _accStatus = SensorAvailability.checking;
  SensorAvailability _gyroStatus = SensorAvailability.checking;
  SensorAvailability _magStatus = SensorAvailability.checking;

  late List<StreamSubscription<dynamic>> _streamSubscriptions;

  Timer? _timeoutTimer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sensor Dashboard')),
      body: Center(child: Text('Sensor data will be displayed here.')),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _streamSubscriptions = <StreamSubscription<dynamic>>[
      _listenToSensor<List<double>>(
        sensorStream: accelerometerEvents.map(
          (event) => [event.x, event.y, event.z],
        ),
        onData: (data) {
          setState(() {
            _accelerometerValues = data;
          });
        },
        updateStatus: (status) {
          setState(() {
            _accStatus = status;
          });
        },
      ),
      _listenToSensor<List<double>>(
        sensorStream: gyroscopeEvents.map(
          (event) => [event.x, event.y, event.z],
        ),
        onData: (data) {
          setState(() {
            _gyroscopeValues = data;
          });
        },
        updateStatus: (status) {
          setState(() {
            _gyroStatus = status;
          });
        },
      ),
      _listenToSensor<List<double>>(
        sensorStream: magnetometerEvents.map(
          (event) => [event.x, event.y, event.z],
        ),
        onData: (data) {
          setState(() {
            _magnetometerValues = data;
          });
        },
        updateStatus: (status) {
          setState(() {
            _magStatus = status;
          });
        },
      ),
    ];
  }

  StreamSubscription<T> _listenToSensor<T>({
    required Stream<T> sensorStream,
    required Function(T) onData, // Veri geldiğinde çalışacak fonksiyon
    required void Function(SensorAvailability)
    updateStatus, // Durumu güncelleyen fonksiyon
  }) {
    return sensorStream.listen(
      (event) {
        // 1. Durum Kontrolü: İlk veri geldiğinde durumu 'available' yap.
        if (_accStatus == SensorAvailability.checking ||
            _gyroStatus == SensorAvailability.checking ||
            _magStatus == SensorAvailability.checking) {
          // Hangi sensörün durumu güncelleniyorsa onu çağır
          updateStatus(SensorAvailability.available);
        }

        // 2. Veriyi Güncelle
        onData(event);
      },
      onError: (e) {
        // Hata oluştuğunda durumu 'unavailable' yap.
        updateStatus(SensorAvailability.unavailable);
      },
      cancelOnError: true,
    );
  }
}
