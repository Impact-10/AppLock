import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/activity_tile.dart';

final activitiesProvider = StateProvider<List<ActivityStatus>>((ref) {
  return List.generate(4, (i) => ActivityStatus(index: i + 1));
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
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () => Navigator.pushNamed(context, '/admin'),
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
    );
  }
}

class ActivityUploadScreen extends StatelessWidget {
  final int index;
  const ActivityUploadScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Activity $index')),
      body: const Center(child: Text('Upload screen stub — camera/gallery')),
    );
  }
}
