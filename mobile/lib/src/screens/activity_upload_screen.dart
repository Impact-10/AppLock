import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_verification_service.dart';
import '../services/storage_service.dart';
import '../widgets/activity_tile.dart';
import 'lock_home_screen.dart';

class ActivityUploadScreen extends ConsumerStatefulWidget {
  final int index;
  const ActivityUploadScreen({super.key, required this.index});

  @override
  ConsumerState<ActivityUploadScreen> createState() => _ActivityUploadScreenState();
}

class _ActivityUploadScreenState extends ConsumerState<ActivityUploadScreen> {
  File? _image;
  bool _verifying = false;
  String? _message;

  Future<void> pickImage(ImageSource src) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: src, imageQuality: 85);
    if (picked != null) {
      setState(() => _image = File(picked.path));
      await StorageService().saveUpload(widget.index, picked.path);
    }
  }

  Future<void> verify() async {
    if (_image == null) return;
    setState(() {
      _verifying = true;
      _message = null;
    });
    final ai = AiVerificationService();
    final result = await ai.verifyImage('task_${widget.index}', _image!);
    setState(() => _verifying = false);
    if (result.pass) {
      await StorageService().setActivityStatus(widget.index, 'verified');
      final activities = ref.read(activitiesProvider.notifier);
      final list = [...ref.read(activitiesProvider)];
      list[widget.index - 1] = list[widget.index - 1].copyWith(status: VerificationStatus.verified);
      activities.state = list;
      if (widget.index == 4) {
        if (mounted) Navigator.pushReplacementNamed(context, '/result');
      } else {
        if (mounted) Navigator.pop(context);
      }
    } else {
      await StorageService().setActivityStatus(widget.index, 'pending');
      setState(() => _message = 'Verification failed. Please re-upload.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Activity ${widget.index}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_image != null)
              Expanded(child: Image.file(_image!, fit: BoxFit.contain))
            else
              const Expanded(child: Center(child: Text('No image selected'))),
            if (_message != null)
              Text(_message!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => pickImage(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: () => pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _verifying ? null : verify,
                child: _verifying ? const CircularProgressIndicator() : const Text('Verify'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
