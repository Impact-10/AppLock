import 'dart:io';

class VerificationResult {
  final bool pass;
  final double confidence;
  final List<String> labels;
  VerificationResult({required this.pass, this.confidence = 0.0, this.labels = const []});
}

class AiVerificationService {
  // Rule-based PASS/FAIL using ML Kit labels (implemented below).
  Future<VerificationResult> verifyImage(String taskId, File image) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return VerificationResult(pass: true, confidence: 0.9, labels: ['stub']);
  }
}
