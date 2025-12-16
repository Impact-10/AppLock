# AppLock — Gateway-Based App Manager

Control app access through a Flutter gateway. Users complete admin-assigned activities before accessing selected apps.

## Platform
- ✅ Android + iOS
- ✅ Firebase Spark plan (no Blaze required)
- ✅ Fully open-source v1

## Features (v1)
- Admin creates users and assigns activities
- Users complete sequential activities (photo-based)
- Access apps via gateway after completion
- Daily automatic relock

## Quick Start

### Setup Firebase
1. Create project at [firebase.google.com](https://firebase.google.com)
2. Enable **Authentication** (Email/Password)
3. Enable **Firestore** (use provided security rules)
4. Download `google-services.json` for Android app
5. Download `GoogleService-Info.plist` for iOS app (optional)

### Clone & Setup
```bash
git clone https://github.com/Impact-10/AppLock.git
cd AppLock/mobile
flutter pub get
flutterfire configure  # Generates firebase_options.dart from google-services.json
```

Note: Do not commit `android/app/google-services.json` or `ios/Runner/GoogleService-Info.plist`. They are gitignored and should remain local. If they were accidentally pushed, rotate the key(s) and see SECURITY.md.

### Run
```bash
flutter run -d android  # or iOS
```

## Folder Structure
```
AppLock/
├── mobile/              # Flutter app
│   ├── lib/src/
│   │   ├── screens/     # UI screens
│   │   ├── services/    # Firebase & storage logic
│   │   ├── widgets/     # Reusable widgets
│   │   └── app.dart     # Routes
│   └── android/         # Android config
├── functions/           # Cloud Functions (v2+)
├── firestore.rules      # Firestore security rules
├── VERSION_1_SPEC.md    # v1 specification
├── KNOWN_LIMITATIONS.md # What's not in v1
└── VERSION_2_TODO.md    # Blaze-dependent features

```

## Firestore Schema
```
admins/{adminId}/users/{userId}
  ├── name, email, userId, isLocked, activities[], selectedApps[]
  └── lastUnlockedDate, createdAt

userProfiles/{userId}
  ├── adminId, name, createdAt
```

## Admin Workflow
1. Login with email/password
2. Create users (generates User ID + password)
3. Click user to manage:
   - Add activities (sequential, photo-based)
   - Lock/unlock user
   - View completion status

## User Workflow
1. Login with User ID + password
2. If locked or new day: Complete activities in order
3. On completion: Access selected apps via gateway
4. Gateway opens apps via intent (Android) or URL scheme (iOS)

## Tech Stack
- **Frontend**: Flutter (Dart), Riverpod, Hive
- **Auth**: Firebase Authentication
- **Data**: Cloud Firestore
- **Fonts**: Poppins

## Permissions
- Camera (for activity photos)
- Photo library (fallback if camera unavailable)

## Deployment
- No special setup needed for v1
- Uses Firebase free tier (Spark plan)

## Next Steps (v2)
See [VERSION_2_TODO.md](VERSION_2_TODO.md) for:
- OpenAI Vision integration (image verification)
- Scheduled daily resets
- Admin review queue
- Push notifications

v2 requires Firebase **Blaze** plan (~$5-10/month).

## Contributing
- Report bugs via Issues
- See [VERSION_1_SPEC.md](VERSION_1_SPEC.md) for architecture

## License
MIT
