# Migration to Gateway Model (v1)

This document outlines changes from the original OS-level enforcement model to the new gateway-based model.

## What Changed

### ❌ Removed (OS-Level Enforcement)
- **AccessibilityService** — No longer monitors foreground app
- **ForegroundService** — No background enforcement
- **Overlay Lock Screen** — Apps are not blocked at OS level
- **PIN Prompt Overlay Activity** — PIN no longer unlocks apps directly
- **MethodChannels** — No native communication for enforcement
- **Native enforcement state** — No SharedPreferences caching of lock state

### ✅ Added (Gateway Model)
- **User Activities Screen** — Sequential activity completion flow
- **Gateway Screen** — App grid/list after activities complete
- **Admin User Detail Screen** — Manage activities and lock state per user
- **Client-side date logic** — Daily reset via `lastUnlockedDate` comparison

## Flow Comparison

### Old (OS Enforcement)
```
Login → Native lock check → Show Overlay if blocked
  → Overlay shows Activities link + PIN prompt
  → Activities screen opens in-app
  → On completion → Overlay disappears automatically
  → User can access locked apps directly from OS
```

### New (Gateway)
```
Login → Check lock status + date → Activities screen (if locked/new day)
  → Complete all activities → Set isLocked=false, lastUnlockedDate=now
  → Gateway screen shows selected apps
  → Tap app to open via intent/scheme
```

## Permissions Change

### Old
- `android.permission.SYSTEM_ALERT_WINDOW` (overlay)
- `android.permission.BIND_ACCESSIBILITY_SERVICE` (accessibility)

### New
- `android.permission.CAMERA` (photo capture)
- `android.permission.READ_MEDIA_IMAGES` (photo library)
- `android.permission.READ_EXTERNAL_STORAGE` (fallback)

## Data Model Simplified

### Old
```json
{
  "lockStatus": "locked|unlocked",
  "currentPin": "1234",
  "allowedToday": true|false,
  "lockedApps": ["com.instagram..."],
  "enforcement_state": {...}
}
```

### New
```json
{
  "isLocked": true|false,
  "activities": [
    { "description": "...", "status": "locked|pending|completed" }
  ],
  "selectedApps": [
    { "label": "Instagram", "package": "...", "scheme": "..." }
  ],
  "lastUnlockedDate": timestamp
}
```

## Firebase Spark Plan Compatibility
- ✅ No Cloud Functions required (v1 uses client-side logic)
- ✅ No scheduled jobs needed
- ✅ No Cloud Storage needed
- ✅ Free tier supports v1 usage patterns
- ⚠️ Upgrade to Blaze plan when adding v2 features (image verification, notifications, scheduled resets)
- ⚠️ Per-user scheduled auto-locks and automatic activity resets are **not** in v1; they require v2 (Cloud Functions + Blaze plan)

## Testing Checklist

- [ ] Admin creates user (generates credentials)
- [ ] User logs in with credentials
- [ ] User sees activities (if locked or new day)
- [ ] User takes photos for all activities
- [ ] Gateway screen appears after activities complete
- [ ] Admin sees user status as "Unlocked"
- [ ] Admin locks user again
- [ ] Next user login shows activities again
- [ ] Multiple users per admin work independently
- [ ] Logout works cleanly

## Deployment Notes

1. **No Cloud Functions deployment required for v1**
   - `functions/src/index.ts` contains only placeholders
   - Can safely skip `firebase deploy --only functions` for v1

2. **Firebase Spark tier sufficient**
   - No Blaze billing triggers in v1
   - Upgrade only when adding v2 features

3. **Mobile app setup unchanged**
   ```bash
   cd mobile
   flutterfire configure
   flutter run
   ```

## Backward Compatibility
- Old Firestore documents will work
- Just ensure new fields (`isLocked`, `lastUnlockedDate`) are added
- Old enforcement-related fields can be ignored
