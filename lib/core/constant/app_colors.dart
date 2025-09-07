import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0066FF);
  static const Color secondary = Color(0xFFFF8A00);
  
  // Power level colors
  static const Color powerVerySlow = Color(0xFFFF3B30);
  static const Color powerSlow = Color(0xFFFF9500);
  static const Color powerNormal = Color(0xFFFFCC00);
  static const Color powerFast = Color(0xFF34C759);
  static const Color powerUltraFast = Color(0xFF007AFF);
  
  // Status colors
  static const Color charging = Color(0xFF34C759);
  static const Color notCharging = Color(0xFFFF3B30);
  
  // Background colors
  static const Color lightBackground = Color(0xFFF2F2F7);
  static const Color darkBackground = Color(0xFF000000);
  static const Color lightCard = Colors.white;
  static const Color darkCard = Color(0xFF1C1C1E);
  
  // Gauge colors
  static const Color voltageGauge = Color(0xFF007AFF);
  static const Color currentGauge = Color(0xFF34C759);
  static const Color inactiveGauge = Color(0xFFE5E5EA);
}