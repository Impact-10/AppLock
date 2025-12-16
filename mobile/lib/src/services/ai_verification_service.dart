import 'dart:io';

class AiVerificationResult {
  final bool pass;
  final String? message;
  const AiVerificationResult({required this.pass, this.message});
}

/// Stubbed AI verification for v1: always passes.
class AiVerificationService {
  Future<AiVerificationResult> verifyImage(String taskId, File image) async {
    // TODO: Integrate real verification (e.g., Cloud Functions / Vision).
    return const AiVerificationResult(pass: true);
  }
}
