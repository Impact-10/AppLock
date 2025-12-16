import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminUserDetailScreen extends StatefulWidget {
  final String userId;
  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  bool loadingActivities = false;
  List<Map<String, dynamic>> activities = [];
  final newActivityCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() { loadingActivities = true; });
    try {
      final adminId = FirebaseAuth.instance.currentUser?.uid;
      if (adminId == null) return;
      final doc = await FirebaseFirestore.instance.collection('admins').doc(adminId).collection('users').doc(widget.userId).get();
      final data = doc.data()?['activities'] as List? ?? [];
      setState(() { activities = data.cast<Map<String, dynamic>>().toList(); });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() { loadingActivities = false; });
    }
  }

  Future<void> _addActivity() async {
    if (newActivityCtrl.text.isEmpty) return;
    try {
      final adminId = FirebaseAuth.instance.currentUser?.uid;
      if (adminId == null) return;
      activities.add({
        'description': newActivityCtrl.text,
        'status': 'locked',
        'allowedSelfComplete': false,
      });
      await FirebaseFirestore.instance.collection('admins').doc(adminId).collection('users').doc(widget.userId).set(
        { 'activities': activities, 'isLocked': true, 'updatedAt': FieldValue.serverTimestamp() },
        SetOptions(merge: true),
      );
      newActivityCtrl.clear();
      if (mounted) setState(() {});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Activity added')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _lockUser() async {
    try {
      final adminId = FirebaseAuth.instance.currentUser?.uid;
      if (adminId == null) return;
      await FirebaseFirestore.instance.collection('admins').doc(adminId).collection('users').doc(widget.userId).set(
        { 'isLocked': true, 'lastUnlockedDate': null, 'updatedAt': FieldValue.serverTimestamp() },
        SetOptions(merge: true),
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User locked')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _unlockUser() async {
    try {
      final adminId = FirebaseAuth.instance.currentUser?.uid;
      if (adminId == null) return;
      await FirebaseFirestore.instance.collection('admins').doc(adminId).collection('users').doc(widget.userId).set(
        { 'isLocked': false, 'lastUnlockedDate': Timestamp.now(), 'updatedAt': FieldValue.serverTimestamp() },
        SetOptions(merge: true),
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User unlocked')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _lockUser, child: const Text('Lock')),
                ElevatedButton(onPressed: _unlockUser, child: const Text('Unlock')),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Activities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            loadingActivities
                ? const Center(child: CircularProgressIndicator())
                : activities.isEmpty
                    ? const Text('No activities. Add one below.')
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: activities.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) {
                          final act = activities[i];
                          return Card(
                            child: ListTile(
                              title: Text(act['description'] ?? 'Activity ${i + 1}'),
                              subtitle: Text('Status: ${act['status'] ?? "locked"}'),
                            ),
                          );
                        },
                      ),
            const SizedBox(height: 16),
            TextField(
              controller: newActivityCtrl,
              decoration: InputDecoration(
                labelText: 'Add activity',
                suffixIcon: IconButton(icon: const Icon(Icons.add), onPressed: _addActivity),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
