// ============================================================
// AppLock Cloud Functions — v2+ (BLAZE PLAN REQUIRED)
// ============================================================
// This file is a PLACEHOLDER for v2 features.
// v1 does NOT require Cloud Functions.
// Deploy these functions ONLY when upgrading to Blaze plan.

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

// ============================================================
// V2: IMAGE VERIFICATION (OpenAI Vision)
// ============================================================
// export const verifyActivityImage = functions.https.onCall(async (data, context) => {
//   if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Auth required');
//   // const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
//   // const response = await openai.vision.create({...});
//   // Update activity status based on confidence
//   return { confidence: 0, labels: [] };
// });

// ============================================================
// V2: SCHEDULED DAILY RESET (Pub/Sub)
// ============================================================
// export const dailyReset = functions.pubsub.schedule('every day 00:05').onRun(async () => {
//   const adminsSnap = await db.collection('admins').get();
//   for (const adminDoc of adminsSnap.docs) {
//     const usersSnap = await adminDoc.ref.collection('users').get();
//     for (const userDoc of usersSnap.docs) {
//       const activities = (userDoc.data().activities || []).map((a: any) => ({
//         ...a,
//         status: 'locked',
//       }));
//       await userDoc.ref.set({
//         activities,
//         isLocked: true,
//         lastUnlockedDate: null,
//         updatedAt: admin.firestore.FieldValue.serverTimestamp(),
//       }, { merge: true });
//     }
//   }
//   return null;
// });

// ============================================================
// V2: ADMIN NOTIFICATIONS (Firestore trigger)
// ============================================================
// export const notifyAdminPendingApproval = functions.firestore
//   .document('pendingApprovals/{approvalId}')
//   .onCreate(async (snap) => {
//     const data = snap.data();
//     const adminId = data.adminId;
//     // Send FCM message to admin
//     // messaging().send({ to: adminToken, ... });
//     return null;
//   });

// ============================================================
// V1 USER CREATION (Client-side in mobile app)
// ============================================================
// v1 creates users directly via Firebase Auth + Firestore.
// No callable function needed.

export const placeholder = functions.https.onRequest((req, res) => {
  res.send('AppLock v2+ functions. Deploy when Blaze plan is enabled.');
});

