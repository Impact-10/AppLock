import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

final activitiesProvider = StateProvider<List<ActivityStatus>>((ref) => []);

enum ActivityStatusEnum { locked, pending, completed }

class ActivityStatus {
  final int index;
  final ActivityStatusEnum status;
  final String? description;
  ActivityStatus({required this.index, this.status = ActivityStatusEnum.locked, this.description});
}

class UserActivitiesScreen extends ConsumerStatefulWidget {
  const UserActivitiesScreen({super.key});

  @override
  ConsumerState<UserActivitiesScreen> createState() => _UserActivitiesScreenState();
}

class _UserActivitiesScreenState extends ConsumerState<UserActivitiesScreen> {
  List<ActivityStatus> activities = [];
  int currentActivityIndex = 0;
  File? selectedImage;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final prof = await FirebaseFirestore.instance.collection('userProfiles').doc(uid).get();
      final adminId = prof.data()?['adminId'] as String?;
      if (adminId == null) return;
      final userDoc = await FirebaseFirestore.instance.collection('admins').doc(adminId).collection('users').doc(uid).get();
      final data = userDoc.data() ?? {};
      final acts = (data['activities'] as List?)?.cast<Map>() ?? <Map>[];
      final statusList = acts.asMap().entries.map((e) {
        final activity = e.value;
        final idx = e.key + 1;
        return ActivityStatus(
          index: idx,
          status: activity['status'] == 'completed' ? ActivityStatusEnum.completed : ActivityStatusEnum.locked,
          description: activity['description'] ?? 'Activity $idx',
        );
      }).toList();
      setState(() { activities = statusList; loading = false; });
    } catch (e) {
      setState(() { loading = false; });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked != null) {
      setState(() { selectedImage = File(picked.path); });
    }
  }

  Future<void> _completeActivity() async {
    if (selectedImage == null) return;
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final prof = await FirebaseFirestore.instance.collection('userProfiles').doc(uid).get();
      final adminId = prof.data()?['adminId'] as String?;
      if (adminId == null) return;
      final userRef = FirebaseFirestore.instance.collection('admins').doc(adminId).collection('users').doc(uid);
      final doc = await userRef.get();
      final activities = (doc.data()?['activities'] as List?)?.map((a) => Map<String, dynamic>.from(a as Map)).toList() ?? [];
      if (currentActivityIndex < activities.length) {
        activities[currentActivityIndex] = {...activities[currentActivityIndex], 'status': 'completed'};
      }
      await userRef.set({'activities': activities, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      setState(() { selectedImage = null; currentActivityIndex++; });
      if (currentActivityIndex >= activities.length) {
        // All activities complete
        await userRef.set({'isLocked': false, 'lastUnlockedDate': Timestamp.now()}, SetOptions(merge: true));
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/user/gateway');
      } else {
        _loadActivities();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (activities.isEmpty) return const Scaffold(body: Center(child: Text('No activities.')));
    final current = activities[currentActivityIndex];
    return Scaffold(
      appBar: AppBar(title: Text('Activity ${current.index} of ${activities.length}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(current.description ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            if (selectedImage != null)
              Expanded(child: Image.file(selectedImage!, fit: BoxFit.contain))
            else
              const Expanded(child: Center(child: Text('Take a photo to proceed'))),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedImage == null ? null : _completeActivity,
                child: const Text('Complete & Continue'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
