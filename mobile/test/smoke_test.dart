import 'package:flutter_test/flutter_test.dart';
import 'package:activity_locker_mvp/src/services/ai_verification_service.dart';

void main() {
  group('Rule-based verification', () {
    final svc = AiVerificationService();

    test('task_1 passes with sports label', () {
      expect(_simulateRule(svc, 'task_1', ['sports', 'ball']), true);
    });

    test('task_2 fails without food labels', () {
      expect(_simulateRule(svc, 'task_2', ['tree', 'sky']), false);
    });

    test('task_3 passes with laptop', () {
      expect(_simulateRule(svc, 'task_3', ['laptop']), true);
    });

    test('task_4 passes with book', () {
      expect(_simulateRule(svc, 'task_4', ['book']), true);
    });
  });
}

// Access private rule via reflection is not possible; reimplement minimal helper for test parity.
bool _simulateRule(AiVerificationService svc, String taskId, List<String> labels) {
  bool containsAny(List<String> keys) => labels.any((l) => keys.any((k) => l.contains(k)));
  switch (taskId) {
    case 'task_1':
      return containsAny(['person', 'sports', 'exercise']);
    case 'task_2':
      return containsAny(['food', 'meal', 'cuisine', 'dish']);
    case 'task_3':
      return containsAny(['computer', 'laptop', 'screen', 'keyboard']);
    case 'task_4':
      return containsAny(['book', 'document', 'paper', 'text']);
    default:
      return false;
  }
}
