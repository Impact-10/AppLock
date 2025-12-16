# Version 2+ Roadmap

## When Blaze Plan is Required
To upgrade to v2 features, Firebase project must be on **Blaze (pay-as-you-go)** plan:
- Enables Cloud Functions
- Enables scheduled jobs
- Enables Cloud Storage for image uploads
- Estimated cost: ~$0 - $10/month for small deployments (free tier: 125k invocations/month)

## v2 Features (Blaze Dependent)

### Image Verification (OpenAI Vision)
- **What**: Server-side verification that uploaded images match activity intent
- **Why**: v1 accepts any image; v2 adds confidence scoring to prevent spam completions
- **Implementation**:
  - Admin sets expected content per activity (e.g., "Exercise", "Reading")
  - User uploads image
  - Cloud Function calls OpenAI Vision API
  - Returns confidence score + labels
  - Admin can approve/reject pending activities
  - Cost: ~$0.01 per image

### Scheduled Daily Resets
- **What**: Automatic daily reset of activities and lock state at UTC midnight
- **Why**: v1 does client-side date check; v2 enforces reset server-side
- **Implementation**:
  - Pub/Sub scheduled function (runs daily at 00:05 UTC)
  - Iterates all users, resets activities and `isLocked = true`
  - Sends notifications to admins
  - Cost: Free (Cloud Functions free tier covers ~125k invocations/month)

### Per-User Scheduled Auto-Lock
- **What**: Admin-defined lock time per user; at that time, user is locked and activity statuses reset to `pending`
- **Why**: Supports daily routines without manual locking
- **Implementation**:
   - Firestore field per user: `autoLockTimeUtc` (e.g., `"22:00"`)
   - Scheduled function reads per-user times, locks matching users, resets activity statuses to `pending`
   - Optional: batch notifications to affected users
   - Cost: Same as scheduled resets (covered by Functions free tier for small scale)

### Admin Review Queue
- **What**: Admins review pending activity submissions with confidence scores
- **Why**: Catches edge cases where user uploads irrelevant images
- **Implementation**:
  - Collection: `pendingApprovals/{approvalId}`
  - Contains image URL, confidence, activity ID
  - Admin dashboard shows pending list with approve/reject buttons
  - Approval updates activity status in user doc
  - Cost: Minimal (Firestore writes + Storage bandwidth)

### Notifications (Push)
- **What**: Notify users when activities are reset, and notify admins of pending approvals
- **Why**: Better UX; admins stay informed
- **Implementation**:
  - Cloud Messaging (FCM) on Android/iOS
  - Cloud Function sends on daily reset or new pending approval
  - Cost: Free (FCM free tier)

### Activity Analytics
- **What**: Admin dashboard shows completion rates, time spent, image quality
- **Why**: Track engagement and effectiveness
- **Implementation**:
  - Activity log collection: `activityLogs/{logId}`
  - Records: user, activity, completion time, image quality, retry count
  - Dashboard aggregates by user/activity
  - Cost: Minimal (Firestore writes)

## v3+ Features (Enterprise)

### Device Admin Enforcement (Android)
- Prevent user from uninstalling app
- Optional secondary verification layer
- Requires enterprise device management (MDM)

### Enhanced Security
- Rate-limiting on login attempts
- IP-based blocking for suspicious activity
- Audit logs for all admin actions

### Paid Plans
- Different activity quotas per user
- Premium image verification (human review option)
- Custom branding

## Upgrade Checklist (v1 → v2)

1. **Upgrade Firebase Project**:
   ```bash
   # In Firebase Console, go to Project Settings → Blaze Plan
   ```

2. **Deploy Cloud Functions**:
   ```bash
   cd functions
   npm i
   npm run build
   firebase deploy --only functions
   ```

3. **Configure OpenAI API**:
   - Create OpenAI account
   - Get API key
   - Store in Firebase Secret Manager or .env.prod
   - Add to Cloud Function environment

4. **Create Cloud Storage**:
   ```bash
   gsutil mb gs://your-applock-images/
   ```

5. **Enable Pub/Sub Scheduling**:
   - No additional setup; Cloud Functions handles it

6. **Update App**:
   - Merge v2 branches
   - Add notification handling
   - Update activity submission to send to review queue
   - Add admin review UI

## Placeholder Configuration (v1 - Do NOT Activate)

### Cloud Functions Entry Point (Not Active)
File: `functions/src/index.ts`

```typescript
// Placeholder for v2 features
// DO NOT DEPLOY in v1

// export const verifyActivityImage = functions.https.onCall(async (data, context) => {
//   // Call OpenAI Vision API
//   // Return { confidence, labels }
// });

// export const dailyReset = functions.pubsub.schedule('every day 00:05').onRun(async () => {
//   // Reset all users
// });

// export const sendNotifications = functions.firestore
//   .document('pendingApprovals/{approvalId}')
//   .onCreate(async (snap) => {
//     // Send admin notification
//   });
```

### Environment Variables (v1 .env - Do NOT Set)
```
# These will be needed in v2
OPENAI_API_KEY=sk-...
OPENAI_MODEL=gpt-4-vision
STORAGE_BUCKET=your-applock-images
ADMIN_NOTIFICATION_TOPIC=admin-pending-approvals
```

### Cost Estimate (v2 with 100 active users)
- Cloud Functions: ~$5/month (invocations + runtime)
- OpenAI Vision: ~$2/month (2 images/user/day)
- Cloud Storage: ~$0.50/month (100 users × 50 images/month)
- Firestore: ~$0.50/month (within free tier for reads)
- **Total**: ~$8/month

## Files to Modify in v2
- `functions/src/index.ts` - Deploy verification, reset, notification functions
- `mobile/lib/src/screens/user_activities_screen.dart` - Send to review queue instead of auto-completing
- `mobile/lib/src/screens/admin_user_detail_screen.dart` - Add approval queue tab
- `mobile/android/app/build.gradle.kts` - Add Cloud Messaging dependency
- `mobile/pubspec.yaml` - Add firebase_messaging

## v2 Feature Branches (Not Started)
- `feature/v2-image-verification`
- `feature/v2-scheduled-reset`
- `feature/v2-notifications`
- `feature/v2-analytics`

