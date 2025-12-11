import 'package:flutter/material.dart';
import 'dart:io';
import '../services/storage_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  Map<int, Map?> uploads = {};
  Map<int, String> statuses = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final storage = StorageService();
    await storage.init();
    final map = <int, Map?>{};
    final stats = <int, String>{};
    for (var i = 1; i <= 4; i++) {
      map[i] = storage.getUpload(i);
      stats[i] = storage.getActivityStatus(i);
    }
    setState(() {
      uploads = map;
      statuses = stats;
    });
  }

  Future<void> _approve(int index) async {
    final storage = StorageService();
    await storage.setActivityStatus(index, 'verified');
    await _load();
  }

  Future<void> _reject(int index) async {
    final storage = StorageService();
    await storage.setActivityStatus(index, 'locked');
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final idx = i + 1;
          final up = uploads[idx];
          final status = statuses[idx] ?? 'locked';
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Activity $idx — status: $status'),
                  const SizedBox(height: 8),
                  if (up != null && up['path'] != null && File(up['path']).existsSync())
                    Image.file(File(up['path']), height: 120, fit: BoxFit.cover)
                  else
                    const Text('No upload'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _approve(idx),
                        icon: const Icon(Icons.check),
                        label: const Text('Approve'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => _reject(idx),
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
