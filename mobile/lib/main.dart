import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'src/app.dart';
import 'src/services/firebase_options_stub.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for Flutter
  await Hive.initFlutter();

  // Open boxes used by the app BEFORE runApp
  await Hive.openBox('activities');
  await Hive.openBox('uploads');

  // Initialize Firebase (expects firebase_options.dart generated later). If not present, use stub.
  try {
    // firebase_options.dart should provide DefaultFirebaseOptions.currentPlatform
    // The stub will fall back to default Firebase.initializeApp()
    await Firebase.initializeApp(
      options: await loadFirebaseOptionsSafely(),
    );
  } catch (_) {
    await Firebase.initializeApp();
  }

  runApp(const ActivityLockerApp());
}
