# HostelHub backend (Firebase)

The backend is Firebase: **Authentication** (email/password, Google, Apple) and
**Cloud Firestore** (hostels, user profiles + favorites, bookings).

```
backend/
├── firestore.rules          security rules (deploy these)
├── firestore.indexes.json   no custom indexes needed
├── firebase.json            lets the Firebase CLI deploy the rules
└── seed/                    uploads the 11 sample hostels
    ├── hostels.json
    ├── seed.js
    └── package.json
```

## 1. Create the Firebase project
1. https://console.firebase.google.com -> Add project.
2. Build -> **Authentication** -> Get started -> Sign-in method: enable
   **Email/Password** and **Google** (and **Apple** for iOS, see step 5).
3. Build -> **Firestore Database** -> Create database (production mode).

## 2. Connect the Flutter app
```
npm install -g firebase-tools
dart pub global activate flutterfire_cli
firebase login
flutterfire configure        # pick your project + android/ios; overwrites lib/firebase_options.dart
flutter pub get
```
Android: set `minSdk = 23` (or higher) in `android/app/build.gradle(.kts)`.

## 3. Deploy the security rules
```
cd backend
firebase use --add           # choose your project
firebase deploy --only firestore:rules
```

## 4. Load the hostels
1. Firebase console -> Project settings -> Service accounts -> **Generate new private key**.
   Save it as `backend/seed/serviceAccountKey.json` (never commit it; it is git-ignored).
2. ```
   cd backend/seed
   export GOOGLE_APPLICATION_CREDENTIALS=./serviceAccountKey.json
   npm install
   npm run seed
   ```
Until this is done you can run the app with `--dart-define=USE_MOCK_HOSTELS=true`.

## 5. Google and Apple sign-in
**Google (Android):** add your app's SHA-1 and SHA-256 in Project settings -> Your apps
(`cd android && ./gradlew signingReport` prints them), then re-run `flutterfire configure`.
**Google (iOS):** copy `REVERSED_CLIENT_ID` from `ios/Runner/GoogleService-Info.plist`
into `ios/Runner/Info.plist` as a URL scheme (CFBundleURLTypes).
**Apple (iOS):** needs an Apple Developer account. Enable the *Sign in with Apple*
capability in Xcode, create a Services ID + key in the Apple Developer portal, and enter
them under Authentication -> Sign-in method -> Apple. The button only shows on iOS.

## Data model
- `hostels/{id}` - listing (rooms and manager embedded), plus `order` for sorting. Read-only for the app.
- `users/{uid}` - name, email, provider, timestamps, `savedHostelIds`.
- `bookings/{id}` - booking fields + `userId`, `status` (`pending` / `cancelled`).

To add a hostel: add it to `hostels.json` (or the Firebase console) and seed again.
Image entries can be `assets/images/...` paths or full `https://` URLs.
