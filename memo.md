import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

void main() {
  runApp(const VoltaApp());
}

class VoltaApp extends StatelessWidget {
  const VoltaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volta - Test de Puissance',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const PowerMonitorPage(),
    );
  }
}

class PowerMeasurement {
  final double voltage;
  final double current;
  final double power;
  final DateTime timestamp;

  PowerMeasurement({
    required this.voltage,
    required this.current,
    required this.power,
    required this.timestamp,
  });
}

class PowerMonitorPage extends StatefulWidget {
  const PowerMonitorPage({super.key});

  @override
  State<PowerMonitorPage> createState() => _PowerMonitorPageState();
}

class _PowerMonitorPageState extends State<PowerMonitorPage>
    with TickerProviderStateMixin {
  static const MethodChannel _channel = MethodChannel('volta/battery_info');

  double voltage = 0.0;
  double current = 0.0;
  double power = 0.0;
  bool isCharging = false;
  bool isMonitoring = false;
  
  Timer? timer;
  List<PowerMeasurement> measurements = [];
  
  // Statistiques
  double maxPower = 0.0;
  double avgPower = 0.0;
  double maxVoltage = 0.0;
  double maxCurrent = 0.0;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _checkInitialState();
  }

  @override
  void dispose() {
    timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkInitialState() async {
    await _getBatteryStats();
  }

  Future<void> _getBatteryStats() async {
    try {
      final Map<dynamic, dynamic>? result =
          await _channel.invokeMethod('getBatteryStats');
      if (result != null) {
        setState(() {
          voltage = (result['voltage'] ?? 0).toDouble();
          current = (result['current'] ?? 0).toDouble();
          power = (result['power'] ?? 0).toDouble();
          isCharging = (result['isCharging'] ?? false);
          
          if (isCharging && isMonitoring) {
            _addMeasurement();
            _updateStatistics();
          }
        });
      }
    } on PlatformException catch (e) {
      debugPrint('Erreur récupération batterie : ${e.message}');
    }
  }

  void _addMeasurement() {
    measurements.add(PowerMeasurement(
      voltage: voltage,
      current: current,
      power: power,
      timestamp: DateTime.now(),
    ));
    
    // Garder seulement les 100 dernières mesures
    if (measurements.length > 100) {
      measurements.removeAt(0);
    }
  }

  void _updateStatistics() {
    if (measurements.isEmpty) return;
    
    maxPower = measurements.map((m) => m.power).reduce(max);
    maxVoltage = measurements.map((m) => m.voltage).reduce(max);
    maxCurrent = measurements.map((m) => m.current).reduce(max);
    avgPower = measurements.map((m) => m.power).reduce((a, b) => a + b) / measurements.length;
  }

  void _startMonitoring() {
    if (isMonitoring) return;
    
    setState(() {
      isMonitoring = true;
      measurements.clear();
      maxPower = 0.0;
      avgPower = 0.0;
      maxVoltage = 0.0;
      maxCurrent = 0.0;
    });
    
    _animationController.forward();
    
    timer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      await _getBatteryStats();
      if (!isCharging) {
        _stopMonitoring();
      }
    });
  }

  void _stopMonitoring() {
    setState(() {
      isMonitoring = false;
    });
    
    _animationController.reverse();
    timer?.cancel();
  }

  void _resetMeasurements() {
    setState(() {
      measurements.clear();
      maxPower = 0.0;
      avgPower = 0.0;
      maxVoltage = 0.0;
      maxCurrent = 0.0;
    });
  }

  Color _getPowerColor(double power) {
    if (power < 5) return Colors.red;
    if (power < 10) return Colors.orange;
    if (power < 15) return Colors.yellow;
    if (power < 20) return Colors.lightGreen;
    return Colors.green;
  }

  String _getChargingQuality(double power) {
    if (power < 5) return 'Très lent';
    if (power < 10) return 'Lent';
    if (power < 15) return 'Normal';
    if (power < 20) return 'Rapide';
    return 'Très rapide';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volta - Test de Puissance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetMeasurements,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isCharging ? Icons.battery_charging_full : Icons.battery_alert,
                          color: isCharging ? Colors.green : Colors.red,
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isCharging ? 'En charge' : 'Pas en charge',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: isCharging ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    if (isCharging) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Qualité: ${_getChargingQuality(power)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _getPowerColor(power),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Gauges
            if (isCharging) ...[
              // Voltage Gauge
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Voltage',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: SfRadialGauge(
                          axes: <RadialAxis>[
                            RadialAxis(
                              minimum: 0,
                              maximum: 12,
                              ranges: <GaugeRange>[
                                GaugeRange(
                                  startValue: 0,
                                  endValue: 4,
                                  color: Colors.red,
                                  startWidth: 10,
                                  endWidth: 10,
                                ),
                                GaugeRange(
                                  startValue: 4,
                                  endValue: 8,
                                  color: Colors.orange,
                                  startWidth: 10,
                                  endWidth: 10,
                                ),
                                GaugeRange(
                                  startValue: 8,
                                  endValue: 12,
                                  color: Colors.green,
                                  startWidth: 10,
                                  endWidth: 10,
                                ),
                              ],
                              pointers: <GaugePointer>[
                                NeedlePointer(
                                  value: voltage,
                                  enableAnimation: true,
                                  animationDuration: 300,
                                ),
                              ],
                              annotations: <GaugeAnnotation>[
                                GaugeAnnotation(
                                  widget: Text(
                                    '${voltage.toStringAsFixed(2)}V',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  angle: 90,
                                  positionFactor: 0.5,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Current and Power Row
              Row(
                children: [
                  // Current Gauge
                  Expanded(
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Courant',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 150,
                              child: SfRadialGauge(
                                axes: <RadialAxis>[
                                  RadialAxis(
                                    minimum: 0,
                                    maximum: 3,
                                    ranges: <GaugeRange>[
                                      GaugeRange(
                                        startValue: 0,
                                        endValue: 1,
                                        color: Colors.red,
                                      ),
                                      GaugeRange(
                                        startValue: 1,
                                        endValue: 2,
                                        color: Colors.orange,
                                      ),
                                      GaugeRange(
                                        startValue: 2,
                                        endValue: 3,
                                        color: Colors.green,
                                      ),
                                    ],
                                    pointers: <GaugePointer>[
                                      NeedlePointer(
                                        value: current,
                                        enableAnimation: true,
                                        animationDuration: 300,
                                      ),
                                    ],
                                    annotations: <GaugeAnnotation>[
                                      GaugeAnnotation(
                                        widget: Text(
                                          '${current.toStringAsFixed(2)}A',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        angle: 90,
                                        positionFactor: 0.5,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Power Gauge
                  Expanded(
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Puissance',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 150,
                              child: SfRadialGauge(
                                axes: <RadialAxis>[
                                  RadialAxis(
                                    minimum: 0,
                                    maximum: 25,
                                    ranges: <GaugeRange>[
                                      GaugeRange(
                                        startValue: 0,
                                        endValue: 5,
                                        color: Colors.red,
                                      ),
                                      GaugeRange(
                                        startValue: 5,
                                        endValue: 15,
                                        color: Colors.orange,
                                      ),
                                      GaugeRange(
                                        startValue: 15,
                                        endValue: 25,
                                        color: Colors.green,
                                      ),
                                    ],
                                    pointers: <GaugePointer>[
                                      NeedlePointer(
                                        value: power,
                                        enableAnimation: true,
                                        animationDuration: 300,
                                      ),
                                    ],
                                    annotations: <GaugeAnnotation>[
                                      GaugeAnnotation(
                                        widget: Text(
                                          '${power.toStringAsFixed(1)}W',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        angle: 90,
                                        positionFactor: 0.5,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Statistics
              if (measurements.isNotEmpty) ...[
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Statistiques',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Max Power', '${maxPower.toStringAsFixed(1)}W'),
                            _buildStatItem('Avg Power', '${avgPower.toStringAsFixed(1)}W'),
                            _buildStatItem('Max Voltage', '${maxVoltage.toStringAsFixed(1)}V'),
                            _buildStatItem('Max Current', '${maxCurrent.toStringAsFixed(1)}A'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mesures: ${measurements.length}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
            
            const SizedBox(height: 24),
            
            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: isCharging && !isMonitoring ? _startMonitoring : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Démarrer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isMonitoring ? _stopMonitoring : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Arrêter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _resetMeasurements,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Instructions
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Connectez votre chargeur au téléphone'),
                    const Text('2. Attendez que le statut affiche "En charge"'),
                    const Text('3. Appuyez sur "Démarrer" pour commencer les mesures'),
                    const Text('4. Observez les valeurs en temps réel'),
                    const Text('5. Utilisez "Reset" pour effacer les statistiques'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}