import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:volta/features/splash_screen/splash_screen.dart';
import 'core/constant/app_string.dart';
import 'core/injection/injection_container.dart' as di;
import 'core/themes/app_themes.dart';
import 'features/battery_monitoring/ui/bloc/battery_monitoring_bloc.dart';
import 'features/battery_monitoring/ui/bloc/battery_monitoring_event.dart';
import 'features/battery_monitoring/ui/page/power_monitor_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const VoltaApp());
}

class VoltaApp extends StatelessWidget {
  const VoltaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,

      theme: AppTheme.lightTheme.copyWith(
        textTheme: AppTheme.lightTheme.textTheme.apply(
          fontFamily: 'Poppins',
        ),
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        textTheme: AppTheme.darkTheme.textTheme.apply(
          fontFamily: 'Poppins',
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
