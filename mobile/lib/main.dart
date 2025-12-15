import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for Flutter
  await Hive.initFlutter();

  // Open boxes used by the app BEFORE runApp
  await Hive.openBox('activities');
  await Hive.openBox('uploads');

  runApp(const ActivityLockerApp());
}
