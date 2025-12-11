import 'package:flutter/material.dart';

enum VerificationStatus { locked, pending, verified }

class ActivityStatus {
  final int index;
  final VerificationStatus status;
  ActivityStatus({required this.index, this.status = VerificationStatus.locked});
  ActivityStatus copyWith({VerificationStatus? status}) => ActivityStatus(index: index, status: status ?? this.status);
}

class ActivityTile extends StatelessWidget {
  final ActivityStatus status;
  final bool enabled;
  final VoidCallback onTap;
  const ActivityTile({super.key, required this.status, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = status.status == VerificationStatus.verified ? const Color(0xFF00C48C) : Colors.grey;
    final icon = status.status == VerificationStatus.verified ? Icons.check_circle : Icons.lock_clock;
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text('Activity ${status.index}'),
          subtitle: Text(_subtitle()),
          trailing: enabled ? const Icon(Icons.chevron_right) : null,
          onTap: enabled ? onTap : null,
        ),
      ),
    );
  }

  String _subtitle() {
    switch (status.status) {
      case VerificationStatus.locked:
        return 'Locked — upload required';
      case VerificationStatus.pending:
        return 'Pending verification';
      case VerificationStatus.verified:
        return 'Verified';
    }
  }
}
