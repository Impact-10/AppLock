# AppLock Mobile (Flutter)

Gateway-based app manager. Complete activities to unlock app access.

## Prerequisites
- Flutter stable (3.0+)
- Android Studio or Xcode
- Firebase project (Spark plan)

## Setup

### 1. Firebase Configuration
```bash
cd mobile
flutter pub get
flutterfire configure
```

This generates `lib/firebase_options.dart` and copies credentials into Android/iOS configs.

### 2. Run on Device/Emulator
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios
```

## First Use
- Choose **Admin** or **User** on entry screen
- Admin: Create users and assign activities
- User: Log in and complete activities to access apps

## Folder Structure
```
lib/src/
├── screens/
│   ├── entry_screen.dart           # Role selection
│   ├── admin_login_screen.dart     # Admin auth
│   ├── admin_panel_screen.dart     # Manage users
│   ├── admin_user_detail_screen.dart  # Activities + lock
│   ├── user_login_screen.dart      # User auth
│   ├── user_activities_screen.dart # Activity flow
│   └── user_gateway_screen.dart    # App gateway
├── services/
│   ├── storage_service.dart        # Hive local cache
└── widgets/
    └── activity_tile.dart          # Reusable widget
```

## Development Notes
- No native code (Android/iOS); pure Flutter + Firebase
- Riverpod for state (minimal in v1)
- Hive for local caching
- image_picker for camera access

## Troubleshooting

### "google-services.json not found"
```bash
flutterfire configure
# Then rebuild
flutter clean && flutter pub get && flutter run
```

### Camera permissions denied
- Grant camera + photo library permissions when prompted
- Or manually enable in Settings → App permissions

### Firebase connection error
- Check `google-services.json` in `android/app/`
- Verify Firebase project settings match project ID

## Testing

### Manual Test Workflow
1. **Admin**: 
   - Login with any email/password (create account if needed)
   - Create user (note ID + password)
2. **User**:
   - Logout from admin
   - Login with generated credentials
   - Complete 2 activities (take photos)
   - See Gateway screen with apps (mock)
3. **Admin**: 
   - Verify user status changed to "Unlocked"
   - Click "Lock" button
4. **User**:
   - Logout and login again
   - Should be back to Activities

## Notes
- v1 accepts any photo; v2 will verify with OpenAI
- App opening is mocked in v1; v2 will implement intents/schemes
- No OS-level enforcement; this is a gateway app only

