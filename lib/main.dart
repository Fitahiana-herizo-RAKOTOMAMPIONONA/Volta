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
          seedColor: Colors.orange,
          brightness: Brightness.light,
          primary: Colors.orange,
          secondary: Colors.black,
          surface: Colors.black,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.black,
          foregroundColor: Colors.orange,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.grey[900],
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.orange,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
          primary: Colors.orange,
          secondary: Colors.black,
          surface: Colors.grey[900]!,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.black,
          foregroundColor: Colors.orange,
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
    if (power < 10) return Colors.orange[300]!;
    if (power < 15) return Colors.orange;
    if (power < 20) return Colors.orange[700]!;
    return Colors.orange[900]!;
  }

  String _getChargingQuality(double power) {
    if (power < 5) return 'Très lent';
    if (power < 10) return 'Lent';
    if (power < 15) return 'Normal';
    if (power < 20) return 'Rapide';
    return 'Ultra rapide';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('VOLTA POWER TEST'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.orange),
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCharging ? Icons.battery_charging_full : Icons.battery_alert,
                            color: isCharging ? Colors.orange : Colors.red,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          isCharging ? 'CHARGEMENT EN COURS' : 'NON EN CHARGE',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: isCharging ? Colors.orange : Colors.red,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    if (isCharging) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'QUALITÉ: ${_getChargingQuality(power)}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: _getPowerColor(power),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'TENSION',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.orange,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: SfRadialGauge(
                          axes: <RadialAxis>[
                            RadialAxis(
                              minimum: 0,
                              maximum: 12,
                              axisLineStyle: const AxisLineStyle(
                                thickness: 10,
                                color: Colors.grey,
                              ),
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
                                  color: Colors.orange[300]!,
                                  startWidth: 10,
                                  endWidth: 10,
                                ),
                                GaugeRange(
                                  startValue: 8,
                                  endValue: 12,
                                  color: Colors.orange,
                                  startWidth: 10,
                                  endWidth: 10,
                                ),
                              ],
                              pointers: <GaugePointer>[
                                NeedlePointer(
                                  value: voltage,
                                  enableAnimation: true,
                                  animationDuration: 300,
                                  needleColor: Colors.orange,
                                  knobStyle: const KnobStyle(
                                    knobRadius: 0.08,
                                    color: Colors.orange,
                                    borderWidth: 0.05,
                                    borderColor: Colors.black,
                                  ),
                                ),
                              ],
                              annotations: <GaugeAnnotation>[
                                GaugeAnnotation(
                                  widget: Text(
                                    '${voltage.toStringAsFixed(2)}V',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'COURANT',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 150,
                              child: SfRadialGauge(
                                axes: <RadialAxis>[
                                  RadialAxis(
                                    minimum: 0,
                                    maximum: 3,
                                    axisLineStyle: const AxisLineStyle(
                                      thickness: 10,
                                      color: Colors.grey,
                                    ),
                                    ranges: <GaugeRange>[
                                      GaugeRange(
                                        startValue: 0,
                                        endValue: 1,
                                        color: Colors.red,
                                      ),
                                      GaugeRange(
                                        startValue: 1,
                                        endValue: 2,
                                        color: Colors.orange[300]!,
                                      ),
                                      GaugeRange(
                                        startValue: 2,
                                        endValue: 3,
                                        color: Colors.orange,
                                      ),
                                    ],
                                    pointers: <GaugePointer>[
                                      NeedlePointer(
                                        value: current,
                                        enableAnimation: true,
                                        animationDuration: 300,
                                        needleColor: Colors.orange,
                                      ),
                                    ],
                                    annotations: <GaugeAnnotation>[
                                      GaugeAnnotation(
                                        widget: Text(
                                          '${current.toStringAsFixed(2)}A',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'PUISSANCE',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 150,
                              child: SfRadialGauge(
                                axes: <RadialAxis>[
                                  RadialAxis(
                                    minimum: 0,
                                    maximum: 25,
                                    axisLineStyle: const AxisLineStyle(
                                      thickness: 10,
                                      color: Colors.grey,
                                    ),
                                    ranges: <GaugeRange>[
                                      GaugeRange(
                                        startValue: 0,
                                        endValue: 5,
                                        color: Colors.red,
                                      ),
                                      GaugeRange(
                                        startValue: 5,
                                        endValue: 15,
                                        color: Colors.orange[300]!,
                                      ),
                                      GaugeRange(
                                        startValue: 15,
                                        endValue: 25,
                                        color: Colors.orange,
                                      ),
                                    ],
                                    pointers: <GaugePointer>[
                                      NeedlePointer(
                                        value: power,
                                        enableAnimation: true,
                                        animationDuration: 300,
                                        needleColor: Colors.orange,
                                      ),
                                    ],
                                    annotations: <GaugeAnnotation>[
                                      GaugeAnnotation(
                                        widget: Text(
                                          '${power.toStringAsFixed(1)}W',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'STATISTIQUES',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.orange,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 2,
                          children: [
                            _buildStatItem('Puissance Max', '${maxPower.toStringAsFixed(1)}W', Icons.offline_bolt),
                            _buildStatItem('Puissance Moy', '${avgPower.toStringAsFixed(1)}W', Icons.show_chart),
                            _buildStatItem('Tension Max', '${maxVoltage.toStringAsFixed(1)}V', Icons.flash_on),
                            _buildStatItem('Courant Max', '${maxCurrent.toStringAsFixed(1)}A', Icons.electric_bolt),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mesures: ${measurements.length}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
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
                _buildActionButton(
                  icon: Icons.play_arrow,
                  label: 'Démarrer',
                  color: Colors.orange,
                  onPressed: isCharging && !isMonitoring ? _startMonitoring : null,
                ),
                _buildActionButton(
                  icon: Icons.stop,
                  label: 'Arrêter',
                  color: Colors.red,
                  onPressed: isMonitoring ? _stopMonitoring : null,
                ),
                _buildActionButton(
                  icon: Icons.refresh,
                  label: 'Reset',
                  color: Colors.grey,
                  onPressed: _resetMeasurements,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INSTRUCTIONS:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionStep(1, 'Connectez votre chargeur'),
                    _buildInstructionStep(2, 'Attendez que le statut affiche "En charge"'),
                    _buildInstructionStep(3, 'Appuyez sur "Démarrer" pour commencer'),
                    _buildInstructionStep(4, 'Observez les valeurs en temps réel'),
                    _buildInstructionStep(5, 'Utilisez "Reset" pour effacer les stats'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildInstructionStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}