# volta

lib/
├── core/                           # Utilitaires & constantes partagées
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_dimensions.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   └── network_info.dart
│   ├── platform/
│   │   └── platform_channel.dart
│   ├── utils/
│   │   ├── date_utils.dart
│   │   └── math_utils.dart
│   └── themes/
│       ├── app_theme.dart
│       └── color_schemes.dart
├── features/                       # Fonctionnalités par domaine
│   └── battery_monitoring/
│       ├── data/                   # Couche de données
│       │   ├── datasources/
│       │   │   ├── battery_local_data_source.dart
│       │   │   └── battery_remote_data_source.dart
│       │   ├── models/
│       │   │   ├── power_measurement_model.dart
│       │   │   └── battery_stats_model.dart
│       │   └── repositories/
│       │       └── battery_repository_impl.dart
│       ├── domain/                 # Couche métier
│       │   ├── entities/
│       │   │   ├── power_measurement.dart
│       │   │   └── battery_stats.dart
│       │   ├── repositories/
│       │   │   └── battery_repository.dart
│       │   └── usecases/
│       │       ├── get_battery_stats.dart
│       │       ├── start_monitoring.dart
│       │       ├── stop_monitoring.dart
│       │       └── calculate_statistics.dart
│       └── presentation/           # Couche présentation
│           ├── bloc/
│           │   ├── battery_monitoring_bloc.dart
│           │   ├── battery_monitoring_event.dart
│           │   └── battery_monitoring_state.dart
│           ├── pages/
│           │   └── power_monitor_page.dart
│           └── widgets/
│               ├── battery_status_card.dart
│               ├── power_gauge_widget.dart
│               ├── voltage_gauge_widget.dart
│               ├── current_gauge_widget.dart
│               ├── statistics_card.dart
│               ├── action_buttons.dart
│               └── instructions_card.dart
└── main.dart