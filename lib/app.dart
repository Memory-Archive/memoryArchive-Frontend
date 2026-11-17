import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_memories/core/constants/app_strings.dart';
import 'package:smart_memories/core/di/injection.dart';
import 'package:smart_memories/core/themes/app_theme.dart';

class SmartMemoriesApp extends StatelessWidget {
  const SmartMemoriesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: getIt<GoRouter>(),
    );
  }
}
