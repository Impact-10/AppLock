import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final idCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> _login() async {
    setState(() { loading = true; error = null; });
    try {
      final email = "${idCtrl.text.trim()}@applock";
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: passCtrl.text,
      );
      // Check if user is locked
      final prof = await FirebaseFirestore.instance.collection('userProfiles').doc(cred.user!.uid).get();
      final adminId = prof.data()?['adminId'] as String?;
      if (adminId == null) throw Exception('No admin assigned');
      final userDoc = await FirebaseFirestore.instance.collection('admins').doc(adminId).collection('users').doc(cred.user!.uid).get();
      final data = userDoc.data() ?? {};
      final isLocked = data['isLocked'] as bool? ?? true;
      final lastUnlocked = (data['lastUnlockedDate'] as Timestamp?)?.toDate();
      final isNewDay = lastUnlocked == null || DateTime.now().difference(lastUnlocked).inDays > 0;
      final shouldShowActivities = isLocked || isNewDay;
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, shouldShowActivities ? '/user/activities' : '/user/gateway');
    } on FirebaseAuthException catch (e) {
      setState(() { error = e.message; });
    } finally {
      if (mounted) setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'User ID')),
            const SizedBox(height: 12),
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            if (error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(error!, style: const TextStyle(color: Colors.red))),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: loading ? null : _login, child: loading ? const CircularProgressIndicator() : const Text('Login'))),
          ],
        ),
      ),
    );
  }
}
