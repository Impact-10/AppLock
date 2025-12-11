import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class VerificationResult {
  final bool pass;
  final double confidence;
  final List<String> labels;
  VerificationResult({required this.pass, this.confidence = 0.0, this.labels = const []});
}

class AiVerificationService {
  // Rule-based PASS/FAIL using ML Kit labels.
  // Example rules per task (simple demo):
  // task_1: must contain 'person' or 'sports'
  // task_2: must contain 'food' or 'meal'
  // task_3: must contain 'computer' or 'laptop' or 'screen'
  // task_4: must contain 'book' or 'document' or 'paper'

  Future<VerificationResult> verifyImage(String taskId, File image) async {
    final options = ImageLabelerOptions(confidenceThreshold: 0.5);
    final labeler = ImageLabeler(options: options);
    final inputImage = InputImage.fromFile(image);

    try {
      final labels = await labeler.processImage(inputImage);
      final names = labels.map((e) => e.label.toLowerCase()).toList();
      final confidence = labels.isEmpty ? 0.0 : labels.map((e) => e.confidence).reduce((a, b) => a > b ? a : b);
      final pass = _applyRules(taskId, names);
      await labeler.close();
      return VerificationResult(pass: pass, confidence: confidence, labels: names);
    } catch (_) {
      await labeler.close();
      return VerificationResult(pass: false, confidence: 0.0, labels: const []);
    }
  }

  bool _applyRules(String taskId, List<String> labels) {
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
}
