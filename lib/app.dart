import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health_duel/core/config/config.dart';
import 'package:health_duel/core/di/injection.dart';
import 'package:health_duel/core/theme/app_theme.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_bloc.dart';

class HealthDuelApp extends StatelessWidget {
  const HealthDuelApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use BlocProvider.value since AuthBloc is a singleton from DI
    // AuthCheckRequested is dispatched once in main.dart
    return BlocProvider.value(
      value: getIt<AuthBloc>(),
      child: MaterialApp.router(
        title: AppConfig.env.appName,
        debugShowCheckedModeBanner: AppConfig.env.isDebug,

        // Theme Configuration
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Follow system theme
        routerConfig: getIt<GoRouter>(),
      ),
    );
  }
}
