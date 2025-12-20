import 'package:flutter/material.dart';
import 'package:health_duel/core/config/config.dart';
import 'package:health_duel/core/di/injection.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration with flavor from launch.json (dart-define FLAVOR)
  AppConfig.init(FlavorUtil.getFlavorFromEnv());

  // Initialize dependency injection
  await initializeDependencies();

  runApp(const HealthDuelApp());
}
