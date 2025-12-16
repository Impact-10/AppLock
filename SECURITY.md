# Security and Secret Handling

This project uses Firebase for the mobile app. Two files MUST NOT be committed:

- `mobile/android/app/google-services.json`
- `mobile/ios/Runner/GoogleService-Info.plist`

Both are now ignored by Git at the root and in `mobile/.gitignore`.

## If secrets were committed previously

1. Rotate Firebase/Google API keys immediately:
   - Open Google Cloud Console → APIs & Services → Credentials.
   - For the exposed key, click "Regenerate key" (or create a new key) and restrict it to Android/iOS app identifiers.
   - Update the new credentials in Firebase (download updated `google-services.json` and/or `GoogleService-Info.plist`).
2. In GitHub, close the secret scanning alert after key rotation.
3. Optionally, purge the secret from history using a rewrite tool (e.g. `git filter-repo` or GitHub's guidance). Only needed if the repo history must be clean.

## Local setup

Keep these files local and never commit them:
- Place `google-services.json` in `mobile/android/app/`.
- Place `GoogleService-Info.plist` in `mobile/ios/Runner/`.
- Run `flutterfire configure` to generate `lib/firebase_options.dart`.

