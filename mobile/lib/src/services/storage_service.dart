import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const uploadsBox = 'uploads';
  static const activitiesBox = 'activities';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(uploadsBox);
    await Hive.openBox(activitiesBox);
  }

  Future<void> saveUpload(int activityIndex, String filePath, {DateTime? timestamp}) async {
    final box = Hive.box(uploadsBox);
    final ts = timestamp ?? DateTime.now();
    await box.put('activity_$activityIndex', {
      'path': filePath,
      'timestamp': ts.toIso8601String(),
    });
  }

  Map? getUpload(int activityIndex) {
    final box = Hive.box(uploadsBox);
    return box.get('activity_$activityIndex');
  }

  Future<void> setActivityStatus(int activityIndex, String status) async {
    final box = Hive.box(activitiesBox);
    await box.put('activity_$activityIndex', status);
  }

  String getActivityStatus(int activityIndex) {
    final box = Hive.box(activitiesBox);
    return box.get('activity_$activityIndex', defaultValue: 'locked');
  }
}
