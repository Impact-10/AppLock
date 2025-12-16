# AppLock v1 — Quick Reference

## What is AppLock?
A Flutter gateway app where users complete admin-assigned activities before accessing selected mobile apps.

## Roles

### Admin
- Create users (system generates User ID + password)
- Assign activities per user
- Lock / Unlock users
- View user status

### User
- Login with User ID + password
- Complete sequential activities (take photos)
- Access selected apps through the gateway
- Auto-locked each day at reset

## User Screens

| Screen | Purpose | Trigger |
|--------|---------|---------|
| Entry | Choose Admin or User | First launch |
| Admin Login | Email + password | Choose Admin |
| User Login | User ID + password | Choose User |
| Admin Dashboard | List users, create users | After admin login |
| User Details | Assign activities, lock/unlock | Click user in dashboard |
| Activities | Complete sequential tasks | User login (if locked) |
| Gateway | Access selected apps | After activities done |

## How It Works

### Day 1: User Logs In (Locked)
```
User Login → Check: isLocked=true? → Show Activities Screen
Take photos for Activity 1, 2, 3, 4
All complete → Set: isLocked=false, lastUnlockedDate=now
Show Gateway Screen with apps
```

### Day 2: User Logs In (Already Unlocked)
```
User Login → Check: isLocked=false AND same day? → Show Gateway Screen
Access apps directly
```

### Day 3: User Logs In (New Day)
```
User Login → Check: lastUnlockedDate < today? → Show Activities Screen again
(Client-side logic compares dates)
Repeat cycle
```

### Admin Locks User
```
Admin → User Details → Click "Lock" 
Set: isLocked=true, lastUnlockedDate=null
Next user login: Activities Screen appears again
```

## Firebase Schema

```
admins/{adminId}
  └─ users/{userId}
       ├─ name: string
       ├─ userId: string ("1215abc123")
       ├─ email: string
       ├─ isLocked: boolean
       ├─ activities: [
       │    { description, status: "locked|completed" }
       │  ]
       ├─ selectedApps: [
       │    { label: "Instagram", package: "com.instagram...", scheme: "..." }
       │  ]
       ├─ lastUnlockedDate: timestamp (or null)
       └─ createdAt: timestamp

userProfiles/{userId}
  ├─ adminId: string
  ├─ userId: string
  ├─ name: string
  └─ createdAt: timestamp
```

## File Structure (Important)

```
mobile/
├─ lib/src/
│  ├─ screens/
│  │  ├─ entry_screen.dart               (Role choice)
│  │  ├─ admin_login_screen.dart         (Email/password)
│  │  ├─ admin_panel_screen.dart         (User list)
│  │  ├─ admin_user_detail_screen.dart   (Activities + lock)
│  │  ├─ user_login_screen.dart          (User ID/password)
│  │  ├─ user_activities_screen.dart     (Photo upload)
│  │  └─ user_gateway_screen.dart        (App grid)
│  ├─ services/
│  │  ├─ storage_service.dart            (Hive local cache)
│  │  └─ firebase_options_stub.dart      (Firebase init)
│  ├─ widgets/
│  │  └─ activity_tile.dart              (Activity card)
│  ├─ app.dart                           (Routes)
│  └─ theme.dart                         (Poppins font)
└─ android/
   └─ app/src/main/AndroidManifest.xml   (Permissions: camera, photos)
```

## Key Logic

### User Login (user_login_screen.dart)
```dart
// Check if locked AND if new day
final userDoc = await Firestore.collection('admins')
  .doc(adminId).collection('users').doc(uid).get();

final isLocked = userDoc['isLocked'] ?? true;
final lastUnlocked = userDoc['lastUnlockedDate'];
final isNewDay = lastUnlocked == null || 
  DateTime.now().difference(lastUnlocked).inDays > 0;

if (isLocked || isNewDay) {
  navigate('/user/activities');  // Show activities
} else {
  navigate('/user/gateway');     // Show apps
}
```

### Activity Completion (user_activities_screen.dart)
```dart
// On last activity completion
await userRef.set({
  'activities': allCompleted,
  'isLocked': false,
  'lastUnlockedDate': Timestamp.now(),
}, SetOptions(merge: true));

navigate('/user/gateway');  // Show apps
```

### Admin Lock (admin_user_detail_screen.dart)
```dart
// Admin clicks "Lock" button
await userRef.set({
  'isLocked': true,
  'lastUnlockedDate': null,
}, SetOptions(merge: true));
```

## Security Rules (firestore.rules)
```
match /admins/{adminId}/users/{userId} {
  allow read, write: if request.auth.uid == adminId
    || request.auth.uid == userId;
}

match /userProfiles/{userId} {
  allow read: if request.auth.uid == userId;
}
```

## Tech Stack
- **Flutter** (Dart)
- **Firebase Auth** (email/password)
- **Firestore** (data store)
- **Riverpod** (state)
- **Hive** (local cache)
- **image_picker** (camera)
- **google_fonts** (Poppins)

## No Cloud Functions in v1
- User creation: Client-side (Firebase Auth + Firestore)
- Daily reset: Client-side (date comparison)
- PIN management: Removed (gateway model doesn't need it)

See **VERSION_2_TODO.md** for Blaze-dependent features.

## Deployment
```bash
cd mobile
flutter pub get
flutterfire configure      # Setup Firebase
flutter run -d android     # Run on device
```

**No backend deployment needed for v1.**

## Common Tasks

### Create a User (Admin)
1. Login as admin
2. Click "+" button
3. Enter name
4. System generates User ID + password
5. Share credentials with user

### Assign Activities (Admin)
1. Login as admin
2. Click user name
3. Type activity description in text field
4. Click add icon
5. Activity added to user's list

### Lock a User (Admin)
1. Login as admin
2. Click user name
3. Click "Lock" button
4. Next time user logs in, activities appear

### Complete Activities (User)
1. Login
2. See activities list
3. Tap each activity
4. Take photo (or use gallery)
5. Click "Complete & Continue"
6. On final activity → Gateway screen

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "No users yet" | Admin: Click "+" to create first user |
| "Invalid credentials" | User: Check User ID and password (case-sensitive) |
| Activities not showing | User: Check `lastUnlockedDate` in Firestore; should be null or old date |
| App won't open | Gateway screen is mocked in v1; v2 will open real apps |
| Firebase error | Run `flutterfire configure` again; check google-services.json |

## Next Steps (v2)
See **VERSION_2_TODO.md**:
- Upgrade to Blaze plan
- Add image verification (OpenAI Vision)
- Scheduled daily resets
- Push notifications
- Admin approval queue

Estimated cost: ~$5-10/month with 100 active users.
