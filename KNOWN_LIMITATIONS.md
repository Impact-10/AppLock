# Known Limitations (v1)

- **App Opening**: Requires app mapping to intents (Android) and URL schemes (iOS). Not all apps can be deeplinked.
- **Activities**: Accept any image; v1 does not verify image content.
- **Daily Reset**: Client-side date comparison; not server-enforced via scheduled functions.
- **No OS Protection**: Apps are accessible directly from OS. AppLock is a gateway, not a system-level lock.
- **iOS URL Schemes**: Requires pre-configuration of each app's URL scheme in Firestore.
- **Firestore Plan**: Spark tier used; 50k reads/day soft limit. Can upgrade to Blaze for higher traffic.

