# Changes Summary — v1 Gateway Model

## Deleted Files

### Native Android Enforcement
- `mobile/android/app/src/main/kotlin/.../AppLockAccessibilityService.kt`
- `mobile/android/app/src/main/kotlin/.../OverlayEnforcementService.kt`
- `mobile/android/app/src/main/kotlin/.../PinOverlayActivity.kt`
- `mobile/android/app/src/main/res/layout/view_lock_overlay.xml`
- `mobile/android/app/src/main/res/layout/activity_pin_overlay.xml`
- `mobile/android/app/src/main/res/xml/accessibility_service_config.xml`

### Old Flutter Screens
- `mobile/lib/src/screens/lock_home_screen.dart` → Removed (replaced by activities + gateway)
- `mobile/lib/src/screens/activity_upload_screen.dart` → Removed (replaced by user_activities_screen)
- `mobile/lib/src/screens/result_screen.dart` → Removed (no final "all done" screen needed)
- `mobile/lib/src/screens/user_lock_setup_screen.dart` → Removed (app selection not in v1)
- `mobile/lib/src/screens/permissions_screen.dart` → Removed (no OS permissions needed)

### Old Services
- `mobile/lib/src/services/native_channel_service.dart` → Removed
- `mobile/lib/src/services/enforcement_cache_service.dart` → Removed
- `mobile/lib/src/services/ai_verification_service.dart` → Removed
- `mobile/lib/src/services/auth_service.dart` → Removed (Firebase Auth used directly)

### Old Widgets
- `mobile/lib/src/widgets/enforcement_syncer.dart` → Removed

### Backend
- Functions code gutted; now placeholder only
- No callable functions deployed for v1

## New Files

### New Flutter Screens
- `mobile/lib/src/screens/user_activities_screen.dart` (Sequential activity completion)
- `mobile/lib/src/screens/user_gateway_screen.dart` (App access after activities)
- `mobile/lib/src/screens/admin_user_detail_screen.dart` (Manage user activities + lock)

### Documentation
- `MIGRATION_V1_GATEWAY.md` (Detailed changelog from OS model to gateway)
- `QUICK_START.md` (User guide for admins and users)
- `VERSION_2_TODO.md` (Comprehensive v2+ roadmap with cost estimates)

## Modified Files

### pubspec.yaml
- ❌ Removed: `camera`, `cloud_functions`, `dio`, `flutter_local_notifications`, `permission_handler`, `google_mlkit_image_labeling`
- ✅ Kept: `image_picker`, `firebase_core`, `firebase_auth`, `cloud_firestore`, `hive`, `google_fonts`, `flutter_riverpod`
- Updated description

### lib/src/app.dart
- Removed: `EnforcementSyncer` wrapper
- Removed: Old route imports (lock_home, permissions, etc.)
- Added: `user_gateway_screen`, `user_activities_screen`
- Added: `onGenerateRoute` for `/admin/user` dynamic routing

### lib/main.dart
- Removed: `NativeChannelService` import
- Kept: Firebase init as-is

### android/app/src/main/AndroidManifest.xml
- ❌ Removed: `SYSTEM_ALERT_WINDOW` permission
- ❌ Removed: Service declarations (OverlayEnforcementService, AppLockAccessibilityService)
- ❌ Removed: PinOverlayActivity
- ❌ Removed: Accessibility service config
- ✅ Kept: Camera + photo permissions
- ✅ Kept: MainActivity
- Cleaned up comments

### lib/src/screens/admin_panel_screen.dart
- Now creates users directly (Firebase Auth) instead of calling Cloud Function
- Shows `isLocked` status instead of `currentPin`
- Routing to user detail screen

### lib/src/screens/user_login_screen.dart
- Added lock status check
- Added `lastUnlockedDate` comparison for daily reset
- Routes to activities or gateway based on lock status

### lib/src/screens/entry_screen.dart
- Removed "Permissions & Disclosures" button

### lib/src/widgets/activity_tile.dart
- Changed enum: `VerificationStatus.verified` → `VerificationStatus.completed`
- Updated status logic for gateway model

### android/app/build.gradle.kts
- Set `minSdk = 26` (was dynamic)

### README.md
- Complete rewrite for gateway model
- Removed native enforcement references
- Clarified: "Pure Flutter + Firebase"

### mobile/README.md
- Rewritten for gateway model
- Removed accessibility + overlay setup
- Clarified: "No native code, pure Flutter"

### VERSION_1_SPEC.md
- Complete rewrite
- Described gateway model
- Removed OS-level enforcement details
- Updated data model

### KNOWN_LIMITATIONS.md
- Rewritten for gateway
- Removed: accessibility, overlay, OS enforcement
- Added: app opening via intents/schemes, client-side reset, Spark plan notes

### functions/src/index.ts
- Deleted all implementations
- Added placeholders with comments for v2 features (image verification, scheduled reset, notifications)
- Added note: "Deploy only on Blaze plan"

### functions/package.json
- Removed: `uuid` dependency

### android/README.md
- Clarified: "v1 is pure Flutter"

### firestore.rules
- No changes (rules remain appropriate)

### .env.example
- No changes

## Behavior Changes

### User Flow
```
Before: Login → Activities → Native Overlay → Direct App Access
After:  Login → Activities → Gateway Screen → App Intent/Scheme
```

### Admin Control
```
Before: Create user → Assign PIN + Activities → Force Relock → Monitor via PIN
After:  Create user → Assign Activities → Lock/Unlock button → Monitor via isLocked flag
```

### Daily Reset
```
Before: Scheduled Cloud Function runs daily → Resets all users
After:  Client-side date check → Compare lastUnlockedDate with today
```

### Activity Completion
```
Before: Any image → Auto-complete → Unlock for day
After:  Photo required → Set isLocked=false + lastUnlockedDate=now → Show Gateway
```

## Firestore Changes

### Old Fields (Removed)
- `currentPin`
- `lockStatus` ("locked" / "unlocked")
- `allowedToday`
- `lockedApps`
- `enforcement_state`

### New Fields (Added)
- `isLocked` (boolean)
- `lastUnlockedDate` (timestamp, nullable)
- `activities[]` with `status: "locked|completed"`
- `selectedApps[]` (mocked in v1)

## No Breaking Changes
- Firestore security rules remain valid
- Firebase Auth works unchanged
- Existing user accounts work (just add new fields)
- Old `currentPin` field can be ignored

## Testing Recommendations

1. **User Creation**: Admin creates user → Verify User ID format
2. **Login Flow**: Login as user → Check route (activities vs gateway)
3. **Activities**: Complete all → Verify gateway appears
4. **Lock/Unlock**: Admin locks user → Next login shows activities
5. **Daily Reset**: Logout → Modify lastUnlockedDate in Firestore → Login → Should see activities
6. **Multiple Users**: Create 2 users → Verify independent states

## Known Gaps (Expected in v1)

- ❌ App opening (just shows "Opening...")
- ❌ App selection UI (selectedApps not in user flow yet)
- ❌ Image verification (any photo accepted)
- ❌ Notifications
- ❌ Audit logs
- ❌ Custom activities per user (fixed 4 activities in schema)

These are documented in **KNOWN_LIMITATIONS.md** and **VERSION_2_TODO.md**.
