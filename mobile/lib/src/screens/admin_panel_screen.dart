import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  String? error;
  bool creating = false;

  Stream<QuerySnapshot<Map<String, dynamic>>> _usersStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('admins')
        .doc(uid)
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _createUserDialog() async {
    final nameCtrl = TextEditingController();
    final res = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create User'),
        content: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, nameCtrl.text.trim()), child: const Text('Create')),
        ],
      ),
    );
    if (res == null || res.isEmpty) return;
    await _createUser(res);
  }

  Future<void> _createUser(String name) async {
    setState(() { creating = true; error = null; });
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Not authenticated');
      // Generate user ID and password
      final ts = DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10);
      final rand = (100000 + (DateTime.now().microsecond % 900000)).toString().substring(0, 5);
      final userId = '$ts$rand';
      final password = (100000 + (DateTime.now().microsecond % 900000)).toString();
      final email = '$userId@applock';
      // Create Firebase Auth user
      final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      // Store in Firestore
      final userRef = FirebaseFirestore.instance.collection('admins').doc(uid).collection('users').doc(userCred.user!.uid);
      await userRef.set({
        'name': name,
        'userId': userId,
        'email': email,
        'isLocked': true,
        'activities': [],
        'selectedApps': [],
        'lastUnlockedDate': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Map user profile to admin
      await FirebaseFirestore.instance.collection('userProfiles').doc(userCred.user!.uid).set({
        'adminId': uid,
        'userId': userId,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('User Created'),
          content: Text('User ID: $userId\nPassword: $password'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
        ),
      );
    } catch (e) {
      setState(() { error = e.toString(); });
    } finally {
      if (mounted) setState(() { creating = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: creating ? null : _createUserDialog,
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'Create User',
          ),
          PopupMenuButton<String>(
            onSelected: (val) async {
              if (val == 'logout') {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              }
            },
            itemBuilder: (ctx) => [const PopupMenuItem(value: 'logout', child: Text('Logout'))],
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _usersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No users yet. Tap + to create.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final d = docs[i].data();
              final name = d['name'] ?? 'Unnamed';
              final userId = d['userId'] ?? '—';
              final isLocked = d['isLocked'] as bool? ?? true;
              return Card(
                child: ListTile(
                  title: Text(name),
                  subtitle: Text('ID: $userId   Status: ${isLocked ? "Locked" : "Unlocked"}'),
                  onTap: () => Navigator.pushNamed(context, '/admin/user', arguments: docs[i].id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
