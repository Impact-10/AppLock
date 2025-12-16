# AppLock — Master Index

**Status**: ✅ v1 Gateway Model Complete (Firebase Spark Plan)

## 📚 Quick Links

### For First-Time Users
1. Start here: [QUICK_START.md](QUICK_START.md) — 5-minute overview
2. Full spec: [VERSION_1_SPEC.md](VERSION_1_SPEC.md) — Detailed architecture
3. Known gaps: [KNOWN_LIMITATIONS.md](KNOWN_LIMITATIONS.md) — What's not in v1

### For Developers
- Setup: [mobile/README.md](mobile/README.md) — Build & run instructions
- Migration: [MIGRATION_V1_GATEWAY.md](MIGRATION_V1_GATEWAY.md) — Changes from old model
- Detailed changelog: [CHANGELOG_V1_GATEWAY.md](CHANGELOG_V1_GATEWAY.md) — File-by-file changes

### For Scaling (v2+)
- Roadmap: [VERSION_2_TODO.md](VERSION_2_TODO.md) — Features, costs, timeline
- Upgrade path: Documented in VERSION_2_TODO.md

## 🏗️ Architecture

### Core Concept
**Gateway model**: Users complete activities → access apps through AppLock app (not OS-level blocking)

### Platform
- ✅ Android + iOS (pure Flutter)
- ✅ Firebase Spark plan (free tier)
- ❌ No native enforcement
- ❌ No OS permissions (no accessibility, no overlay, no device admin)

### Roles
| Role | Can | Setup |
|------|-----|-------|
| Admin | Create users, assign activities, lock/unlock | Email/password login |
| User | Complete activities, access apps via gateway | Generated User ID + password |

## 📂 Folder Structure

```
AppLock/
├─ mobile/                     # Flutter app (main deliverable)
│  ├─ lib/src/
│  │  ├─ screens/             # 7 screens (entry, auth, dashboard, activities, gateway)
│  │  ├─ services/            # Firebase integration + local storage
│  │  ├─ widgets/             # Reusable components
│  │  ├─ app.dart             # Routes
│  │  └─ theme.dart           # Poppins font, colors
│  ├─ android/                # Android config (minimal)
│  ├─ ios/                    # iOS config (minimal)
│  ├─ pubspec.yaml            # Dependencies
│  └─ README.md               # Setup instructions
├─ functions/                 # Cloud Functions (v2+ only)
│  ├─ src/index.ts           # Placeholders for v2 features
│  ├─ package.json           # Dependencies
│  └─ tsconfig.json          # TypeScript config
├─ android/                   # Docs (native code not used in v1)
├─ firestore.rules           # Security rules
├─ .env.example              # Environment template
└─ Docs/ (various)
   ├─ VERSION_1_SPEC.md           # v1 specification
   ├─ KNOWN_LIMITATIONS.md        # v1 gaps
   ├─ VERSION_2_TODO.md           # v2+ features & costs
   ├─ QUICK_START.md              # User guide
   ├─ MIGRATION_V1_GATEWAY.md     # Old → new model
   ├─ CHANGELOG_V1_GATEWAY.md     # File changes
   └─ README.md                   # Overview
```

## 🚀 Quick Start (5 Minutes)

### 1. Create Firebase Project
- Go to [firebase.google.com](https://firebase.google.com)
- Create project
- Enable **Authentication** (Email/Password)
- Enable **Firestore**
- Add Android app, download `google-services.json`

### 2. Clone & Setup
```bash
git clone https://github.com/Impact-10/AppLock.git
cd AppLock/mobile
flutter pub get
flutterfire configure     # Paste google-services.json here
flutter run -d android    # Run on device
```

### 3. First Use
- **Admin**: Login with any email/password (create account)
- **User**: Have admin create user and share credentials
- **User**: Complete activities → access gateway

## 🔄 User Flows

### Admin Workflow
```
1. Login (email/password) → Dashboard
2. Click "+" → Create user (system generates ID + password)
3. Click user → Assign activities, lock/unlock
4. Monitor user status (locked/unlocked)
```

### User Workflow
```
1. Login (User ID + password) → Check lock status
2. If locked/new day → Activities screen (take photos)
3. On completion → Gateway screen (view apps)
4. Tap app → Opens (v2 will implement intent/scheme)
```

## 📊 Data Model

### Firestore Collections
```
admins/{adminId}/
  users/{userId}/
    ├─ name, userId, email, isLocked
    ├─ activities[] → { description, status }
    ├─ selectedApps[] → { label, package, scheme }
    ├─ lastUnlockedDate (timestamp)
    └─ createdAt (timestamp)

userProfiles/{userId}/
  ├─ adminId, name, userId, createdAt
```

### Key Logic
- **Daily Reset**: Client-side, via `lastUnlockedDate` comparison
- **Lock Status**: `isLocked` boolean + date check
- **Activity Completion**: Photo required, sets `isLocked=false` + `lastUnlockedDate=now`

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart) |
| State | Riverpod |
| Storage | Hive (local) |
| Auth | Firebase Auth |
| Database | Firestore |
| Deployment | Firebase Spark plan |
| Fonts | Poppins (Google Fonts) |
| Camera | image_picker |

## ✅ Checklist (v1 Complete)

- [x] Admin creation + authentication
- [x] User creation (system-generated credentials)
- [x] Activity assignment per user
- [x] Activity completion (photo-based)
- [x] Lock / Unlock user manually
- [x] Daily reset (client-side date logic)
- [x] Gateway screen (app list UI)
- [x] Logout with cleanup
- [x] Firestore integration
- [x] Security rules
- [x] Comprehensive documentation
- [x] Firebase Spark plan compatible

## ⚠️ Not in v1 (Documented for v2)

- ❌ App opening via intents/schemes (mocked in gateway)
- ❌ App selection UI (selectedApps field exists, not wired)
- ❌ Image verification (any photo accepted)
- ❌ Cloud Functions (no scheduled resets)
- ❌ Notifications
- ❌ Analytics
- ❌ OS-level blocking
- ❌ Paid tiers

See **[VERSION_2_TODO.md](VERSION_2_TODO.md)** for detailed v2+ features.

## 💰 Costs (v1)

| Component | Cost |
|-----------|------|
| Firebase Spark | Free |
| Flutter development | Free |
| Deployment | Free |
| **Total** | **Free** |

For v2 (with image verification):
- Blaze plan: ~$5-10/month (100 users)
- OpenAI Vision API: ~$2/month (200 images/month)

## 📖 Documentation Files

| File | Purpose | Audience |
|------|---------|----------|
| [QUICK_START.md](QUICK_START.md) | How to use the app | End users |
| [VERSION_1_SPEC.md](VERSION_1_SPEC.md) | Architecture & features | Developers |
| [KNOWN_LIMITATIONS.md](KNOWN_LIMITATIONS.md) | What's not included | Everyone |
| [VERSION_2_TODO.md](VERSION_2_TODO.md) | Future features & costs | Product managers |
| [MIGRATION_V1_GATEWAY.md](MIGRATION_V1_GATEWAY.md) | Old vs new model | Developers |
| [CHANGELOG_V1_GATEWAY.md](CHANGELOG_V1_GATEWAY.md) | Detailed changes | Code reviewers |
| [mobile/README.md](mobile/README.md) | Setup & build | Developers |
| [android/README.md](android/README.md) | Native code notes (v2+) | Android developers |
| [README.md](README.md) | Project overview | Everyone |

## 🔐 Security

- ✅ Firestore security rules (admin/user separation)
- ✅ Firebase Auth (no passwords stored locally)
- ✅ Secure storage for sensitive data (optional)
- ⚠️ No encryption for local activity cache (Hive)
- ⚠️ No audit logs (v2 feature)

## 🧪 Testing

### Manual Test Scenarios
1. **Create User**: Admin creates user, note credentials
2. **Login**: User logs in, sees activities (if locked)
3. **Complete Activities**: Take photos, complete all
4. **Gateway**: After completion, see app grid
5. **Lock Again**: Admin locks user, next login shows activities
6. **Daily Reset**: Modify `lastUnlockedDate` in Firestore, login again (should show activities)

### Edge Cases
- Multiple users under one admin
- Login without any users created
- Incomplete activity (logout mid-flow)
- Logout and re-login same day
- Activities with special characters in description

## 📞 Support

### Issues
- Use GitHub Issues for bug reports
- Reference [KNOWN_LIMITATIONS.md](KNOWN_LIMITATIONS.md) for documented gaps

### Contributing
- See [VERSION_1_SPEC.md](VERSION_1_SPEC.md) for architecture before PRs
- Follow Dart style guide (dartfmt, flutter analyze)

## 📈 Roadmap

| Version | Features | Estimated Timeline |
|---------|----------|-------------------|
| v1 | Gateway model, activities, lock/unlock | ✅ Done |
| v2 | Image verification, notifications, scheduled reset | Q2 2025 (Blaze plan required) |
| v3 | Analytics, paid plans, device admin | Q3 2025+ |

## 🎉 Summary

**AppLock v1 is a production-ready gateway app** that allows admins to control user access through activity completion. Built with Flutter, Firebase, and designed for the free Spark plan.

- ✅ Fully functional
- ✅ iOS + Android compatible
- ✅ No OS-level enforcement needed
- ✅ Comprehensive documentation
- ✅ Clear upgrade path to v2

**Ready to deploy!**

---

**Last Updated**: December 16, 2025  
**Model**: Gateway-Based (v1)  
**Platform**: Firebase Spark (Free)
