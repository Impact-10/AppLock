# Native Android Code (v1 - Gateway Model)

**AppLock v1 is pure Flutter.** There is no native Android enforcement code required.

The `mobile/android` folder contains standard Flutter app configuration only:
- Build settings (build.gradle.kts)
- Android manifest
- Minimal MainActivity (delegates to Flutter)

## If You Need Native Integration Later (v2+)

For future app-opening via intents, add a simple service under:
```
mobile/android/app/src/main/kotlin/com/example/activity_locker_mvp/AppLauncherService.kt
```

This will handle platform-specific intent launching. But in v1, this is mocked in Dart.

