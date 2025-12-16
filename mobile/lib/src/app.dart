import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import 'screens/entry_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/user_login_screen.dart';
import 'screens/admin_panel_screen.dart';
import 'screens/admin_user_detail_screen.dart';
import 'screens/user_gateway_screen.dart';
import 'screens/user_activities_screen.dart';

class ActivityLockerApp extends StatelessWidget {
  const ActivityLockerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'AppLock',
        theme: buildTheme(),
        routes: {
          '/': (_) => const EntryScreen(),
          '/admin/login': (_) => const AdminLoginScreen(),
          '/user/login': (_) => const UserLoginScreen(),
          '/admin/dashboard': (_) => const AdminPanelScreen(),
          '/user/gateway': (_) => const UserGatewayScreen(),
          '/user/activities': (_) => const UserActivitiesScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/admin/user') {
            return MaterialPageRoute(
              builder: (_) => AdminUserDetailScreen(userId: settings.arguments as String),
            );
          }
          return null;
        },
      ),
    );
  }
}
