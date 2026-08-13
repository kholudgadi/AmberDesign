# Firebase setup required for mobile

The application code for phone OTP and push notifications is present, but the Firebase project must be connected before testing on a device.

1. Install and authenticate the Firebase and FlutterFire CLIs.
2. From `frontend/`, run `flutterfire configure` and select Android and iOS.
3. In Firebase Console, enable Authentication > Phone.
4. Add Android SHA-1 and SHA-256 fingerprints to the Firebase Android app.
5. Put the generated Android/iOS configuration files in their standard platform locations.
6. Configure APNs in Firebase for iOS push notifications.
7. Give the backend Firebase Admin credentials using `FIREBASE_SERVICE_ACCOUNT_JSON` and set `FIREBASE_PROJECT_ID`.
8. For development, add Firebase test phone numbers before sending real SMS messages.

Do not commit a Firebase service-account private key. Client Firebase configuration files contain app identifiers, but the Admin service-account JSON is a server secret.

The browser build remains available for UI previews. Phone OTP and device push registration intentionally run only on Android/iOS.
