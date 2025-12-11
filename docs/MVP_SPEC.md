# MVP_SPEC.md

## Project: Activity Locker — MVP spec (mobile Flutter app)

### Purpose (MVP)
A mobile Flutter app that acts as an **activity-gated locker**: users must complete a sequence of 4 assigned activities (upload proofs) in order to reach a final “All tasks complete” state. AI verifies uploaded images automatically; admin can manually override/verify. For MVP we do **not** implement true OS-level unlocking of other apps; the app shows a final success screen only.

### Core MVP features
- Flutter app (Android & iOS)
- 4 sequential activities (default set for the MVP; admin-editable future)
- Upload (camera/gallery) and local storage of images
- On-device AI verification via Google ML Kit image labeling (primary)
- Cloud AI verification optional (Gemini via Vertex AI / OpenAI Vision) — via server proxy
- Admin panel inside the app to manually approve/reject uploads
- Local persistence (Hive) and offline retry
- Basic auth stub for admin
- CI: flutter analyze & flutter test

### Platform caveats & important compliance notes
- **Android**: App-locking other apps usually requires AccessibilityService / UsageStats / special privileges. Play Console requires you to declare AccessibilityService usage and to provide justification & prominent disclosure. If you plan to block other apps at OS level, accept Play Console policy requirements and extra review. :contentReference[oaicite:8]{index=8}
- **Android package visibility**: since Android 11 (API 30), package visibility is restricted. To detect installed or foreground apps you must use queries in the manifest and handle privacy constraints. :contentReference[oaicite:9]{index=9}
- **iOS**: iOS does NOT allow third-party apps to block or prevent access to other apps or detect the foreground app for App Store distributed apps — only possible via MDM for supervised devices. If your client requires iOS-level locking, discuss MDM or exclude iOS. (Document in client questions.)
- **Privacy**: images should be processed on-device by default to minimize privacy risk. If cloud verification is used, obtain user consent and provide a privacy policy.

### AI options (MVP default & fallback)
- Default: **Google ML Kit image labeling** (on-device). Good for detecting objects/scenes and offline verification. :contentReference[oaicite:10]{index=10}
- Cloud fallback (optional): **Google Vertex AI / Gemini** (image understanding) or **OpenAI Vision/Responses** for more flexible multimodal checks. Cloud calls must be proxied via server endpoints; never embed live keys in the app. :contentReference[oaicite:11]{index=11}

### Admin questions to clarify before full product build
1. Do you require OS-level locking on Android? (Yes/No) — if Yes, accept Play policy & additional permissions.
2. iOS locking required? (Yes/No) — if Yes, understand only MDM/supervised devices make this possible.
3. Which AI verification provider to use in production? (on-device ML Kit / Vertex Gemini / OpenAI / custom)
4. Are uploads to be stored server-side? If yes, retention policy?
5. How are tasks assigned to users? (manual admin assignment / server-driven / templated by role)
6. What counts as a valid proof for each activity? Provide sample images or rules.
7. Auth model for users and admin (email/pass, SSO)?
8. Do you want manual admin override? (default: yes)
9. Do you need audit logs and exportable CSV reports?

### Required env variables (example)
- CLOUD_AI_PROVIDER=
- OPENAI_API_KEY=
- VERTEX_API_KEY=
- SERVER_BASE_URL=
- ADMIN_USERNAME=
- ADMIN_PASSWORD=

### Future work (not in MVP)
- OS-level app locking on Android + Play Console compliance
- App-to-app integration to actually prevent launching other apps
- Multi-user / tenant onboarding & full backend (user accounts, server logic)
- Push notifications + web admin console
- Analytics, RBAC, and billing
- Automated ML model training / custom classifiers for activity verification

### Run instructions (dev)
(Place in /mobile/README.md)
1. Install Flutter SDK (stable)
2. `cd mobile`
3. `flutter pub get`
4. `flutter run` (choose emulator or device)
5. For ML Kit on-device labeler ensure Android & iOS build settings include required configs.

### References & important docs
- Play Console AccessibilityService policy. :contentReference[oaicite:12]{index=12}
- Android package visibility guide. :contentReference[oaicite:13]{index=13}
- Google ML Kit Image Labeling (Flutter plugin). :contentReference[oaicite:14]{index=14}
- Gemini / Vertex AI image understanding (optional cloud). :contentReference[oaicite:15]{index=15}
- OpenAI Images & Vision docs (optional cloud). :contentReference[oaicite:16]{index=16}
