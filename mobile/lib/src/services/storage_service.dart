import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  Future<void> init() async {
    await Hive.initFlutter();
  }
}
