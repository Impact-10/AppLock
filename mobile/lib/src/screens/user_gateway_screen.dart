import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserGatewayScreen extends StatefulWidget {
  const UserGatewayScreen({super.key});

  @override
  State<UserGatewayScreen> createState() => _UserGatewayScreenState();
}

class _UserGatewayScreenState extends State<UserGatewayScreen> {
  List<Map<String, dynamic>> selectedApps = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final prof = await FirebaseFirestore.instance.collection('userProfiles').doc(uid).get();
      final adminId = prof.data()?['adminId'] as String?;
      if (adminId == null) return;
      final userDoc = await FirebaseFirestore.instance.collection('admins').doc(adminId).collection('users').doc(uid).get();
      final data = userDoc.data() ?? {};
      final apps = (data['selectedApps'] as List?)?.cast<Map>() ?? <Map>[];
      setState(() { selectedApps = apps.cast<String, dynamic>().toList(); loading = false; });
    } catch (e) {
      setState(() { loading = false; });
    }
  }

  void _openApp(Map<String, dynamic> app) {
    // TODO: Implement native app opening via intent (Android) or URL scheme (iOS)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening ${app['label']}...')),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gateway'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) { if (val == 'logout') _logout(); },
            itemBuilder: (ctx) => [const PopupMenuItem(value: 'logout', child: Text('Logout'))],
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : selectedApps.isEmpty
              ? const Center(child: Text('No apps selected.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.2),
                  itemCount: selectedApps.length,
                  itemBuilder: (ctx, i) {
                    final app = selectedApps[i];
                    return GestureDetector(
                      onTap: () => _openApp(app),
                      child: Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.apps, size: 32),
                            const SizedBox(height: 8),
                            Text(app['label'] ?? 'App', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
