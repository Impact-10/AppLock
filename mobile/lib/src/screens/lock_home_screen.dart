import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/activity_tile.dart';
import '../services/storage_service.dart';
import '../services/native_channel_service.dart';
import 'activity_upload_screen.dart';

final activitiesProvider = StateProvider<List<ActivityStatus>>((ref) {
  final storage = StorageService();
  storage.init();
  return List.generate(4, (i) {
    final statusStr = storage.getActivityStatus(i + 1);
    final status = switch (statusStr) {
      'verified' => VerificationStatus.verified,
      'pending' => VerificationStatus.pending,
      _ => VerificationStatus.locked,
    };
    return ActivityStatus(index: i + 1, status: status);
  });
});

class LockHomeScreen extends ConsumerWidget {
  const LockHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Locker'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) async {
              if (val == 'logout') {
                // Safety logout: disable enforcement and sign out
                try { await NativeChannelService().stopEnforcement(); } catch (_) {}
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                }
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: activities.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final enabled = i == 0
                ? true
                : activities[i - 1].status == VerificationStatus.verified;
            return ActivityTile(
              status: activities[i],
              enabled: enabled,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ActivityUploadScreen(index: i + 1),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/user/setup'),
        icon: const Icon(Icons.lock_outline),
        label: const Text('Edit locked apps'),
      ),
    );
  }
}

// ActivityUploadScreen moved to its file (activity_upload_screen.dart)
