import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import 'screens/lock_home_screen.dart';
import 'screens/admin_panel_screen.dart';
import 'screens/result_screen.dart';

class ActivityLockerApp extends StatelessWidget {
  const ActivityLockerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Activity Locker',
        theme: buildTheme(),
        routes: {
          '/': (_) => const LockHomeScreen(),
          '/admin': (_) => const AdminPanelScreen(),
          '/result': (_) => const ResultScreen(),
        },
      ),
    );
  }
}
