import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/injection/injection_container.dart' as di;
import '../battery_monitoring/ui/bloc/battery_monitoring_bloc.dart';
import '../battery_monitoring/ui/bloc/battery_monitoring_event.dart';
import '../battery_monitoring/ui/page/power_monitor_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
   void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) { // sécurité pour éviter null
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BlocProvider(
              create: (context) =>
                  di.sl<BatteryMonitoringBloc>()..add(InitialBatteryCheck()),
              child: const PowerMonitorPage(),
            ),),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/gif/logo.gif",
                width: MediaQuery.of(context).size.width / 1.5,
              ),
            ],
          ),
        ));
  }
}
