import 'package:flutter/material.dart';
import 'package:smart_memories/app.dart';
import 'package:smart_memories/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const SmartMemoriesApp());
}
