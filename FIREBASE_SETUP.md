# Firebase Setup Guide for NutriTrack India

This guide documents the Firebase setup expected by this repo, including Auth,
Firestore, Storage, rules deployment, Android SHA fingerprints, email
verification, and the common reasons OTP/SMS messages do not arrive.

Official references:

- Flutter Firebase setup: https://firebase.google.com/docs/flutter/setup
- Flutter phone auth: https://firebase.google.com/docs/auth/flutter/phone-auth
- Android phone auth details: https://firebase.google.com/docs/auth/android/phone-auth
- SHA fingerprints: https://support.google.com/firebase/answer/9137403
- Security rules deployment: https://firebase.google.com/docs/rules/manage-deploy

## Current repo status

The app is a Flutter Android and web/PWA app using these Firebase products:

- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Remote Config
- Google Sign-In
- Firebase Phone Auth for SMS OTP during registration

The Android package name is:

```text
com.example.nutri_tracker
```

The checked-in `lib/firebase_options.dart` contains Android options and reads
web options from compile-time `FIREBASE_WEB_*` values. Use the ignored
`config/firebase.web.json` file described in `README.md` for web builds. Before
building iOS, run `flutterfire configure`, select the Apple app, and complete
the Xcode/CocoaPods setup described in `CODEBASE_AUDIT.md`.

The app currently supports:

- Email/password sign-up and sign-in
- Firebase email verification links
- Firebase password reset emails
- Google Sign-In
- SMS OTP verification for the registration phone number

During registration, the app calls `verifyPhoneNumber`, asks for the SMS OTP,
creates the email/password account, links the verified phone credential to that
account, then stores the phone number in Firestore. Firebase Console must have
Phone provider enabled or no SMS OTP will be sent.

Because this app targets Indian nutrition tracking, a 10 digit phone number is
sent to Firebase as `+91{number}`. Users can also enter a full E.164 number such
as `+919876543210`.

## 1. Install required tools

Install Flutter and confirm your environment:

```bash
flutter doctor
flutter --version
```

Install Firebase CLI:

```bash
npm install -g firebase-tools
firebase login
firebase --version
```

Install FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
flutterfire --version
```

On Windows, add Dart global executables to `PATH` if `flutterfire` is not found:

```text
%LOCALAPPDATA%\Pub\Cache\bin
```

Install project dependencies:

```bash
flutter pub get
```

## 2. Create or select a Firebase project

1. Open https://console.firebase.google.com.
2. Create a Firebase project or select the existing NutriTrack project.
3. Enable Google Analytics only if you need Firebase products that benefit from
   it. This app does not require Analytics to boot.
4. Open Project settings.

## 3. Register the Android app

In Firebase Console:

1. Go to Project settings.
2. Select Add app.
3. Choose Android.
4. Enter this Android package name:

```text
com.example.nutri_tracker
```

5. Register the app.
6. Download `google-services.json`.
7. Put it here:

```text
android/app/google-services.json
```

The Gradle file already applies the Google services plugin:

```gradle
id 'com.google.gms.google-services'
```

## 4. Add SHA-1 and SHA-256 fingerprints

SHA fingerprints are required for Google Sign-In and are also important for
Firebase Phone Auth on Android.

From the repo root on Windows PowerShell:

```powershell
cd android
.\gradlew signingReport
```

From bash:

```bash
cd android
./gradlew signingReport
```

Copy the `SHA1` and `SHA-256` values for the `debug` variant into Firebase:

1. Firebase Console.
2. Project settings.
3. Your Android app.
4. Add fingerprint.
5. Add both SHA-1 and SHA-256.
6. Download a fresh `google-services.json`.
7. Replace `android/app/google-services.json`.

For release builds, also add the release keystore SHA-1 and SHA-256. If the app
is published through Google Play App Signing, add the Play app signing
certificate fingerprints from Play Console too.

## 5. Run FlutterFire configuration

From the repo root:

```bash
flutterfire configure
```

Select:

- The Firebase project for NutriTrack
- Android
- iOS/web only if you have registered those apps in Firebase

This updates:

```text
lib/firebase_options.dart
firebase.json
```

The app initializes Firebase in `lib/main.dart` using:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## 6. Enable Authentication providers

In Firebase Console, open Authentication, then Sign-in method.

Enable:

- Email/Password
- Google

For Email/Password, Firebase sends verification as an email link, not an OTP.
This app calls `sendEmailVerification()` after registration and also resends a
verification link when an unverified email/password user tries to sign in.

For password reset, this app calls `sendPasswordResetEmail()`. That also sends
an email link, not an OTP.

## 7. Enable Phone Auth for SMS OTP

Firebase SMS OTP requires Firebase Phone Authentication. It is separate from
email verification links and password reset links.

Firebase Console setup:

1. Open Authentication.
2. Open Sign-in method.
3. Enable Phone.
4. Add test phone numbers while developing. Test numbers avoid SMS quota,
   carrier filtering, and regional delivery problems.
5. Confirm Android SHA-1 and SHA-256 fingerprints are present.
6. Download a fresh `google-services.json` after changing Android app settings.

App code in this repo:

- Registration calls `FirebaseAuth.instance.verifyPhoneNumber(...)`.
- The UI shows a `Send OTP` / `Resend OTP` button.
- The UI captures the SMS OTP.
- Signup creates the email/password user and links the phone credential.
- Firestore stores the phone number in E.164 format.

## 8. OTP/SMS not coming checklist

Use this checklist only for Firebase Phone Auth SMS OTP. It does not apply to
Firebase email verification links.

- Phone provider is enabled in Firebase Authentication.
- The registration screen is using the `Send OTP` button before signup.
- Phone number is entered in E.164 format, for example `+919876543210`.
- The physical Android device has working network and can receive SMS.
- The app has correct SHA-1 and SHA-256 fingerprints in Firebase Console.
- `google-services.json` was downloaded again after adding fingerprints.
- You are not testing only on an emulator that cannot receive SMS.
- Firebase SMS quota has not been exceeded.
- The destination country/region is supported for Firebase Phone Auth.
- SMS region policy is not blocking the destination country.
- The Firebase project is not restricted by billing, abuse checks, or temporary
  rate limits.
- On Android, Play Integrity verification can run on the device. Devices
  without Google Play services or heavily modified system images can fail.
- You are using Firebase Console test phone numbers for development when
  possible.

## 9. Email verification link not coming checklist

Use this checklist for the current app flow.

- Email/Password provider is enabled.
- The user entered a valid email address.
- Check spam, promotions, and blocked sender folders.
- Wait a few minutes before retrying; repeated sends can trigger
  `too-many-requests`.
- Try signing in again. The app now resends a verification link for unverified
  email/password users.
- In Firebase Console, check Authentication templates for email verification.
- Confirm your Firebase project is not disabled or over quota.
- Confirm the device has internet access.

## 10. Create Cloud Firestore

In Firebase Console:

1. Open Firestore Database.
2. Create database.
3. Choose production mode.
4. Select a region close to your users.

The app uses these main collections:

- `user_details`
- `daily_logs`
- `weight_history`
- `favourites`
- `food_data`
- `indian_foods`
- `ai_chats`

Deploy the repo rules instead of leaving console defaults.

## 11. Create Firebase Storage

In Firebase Console:

1. Open Storage.
2. Create the default bucket.
3. Keep production rules.
4. Deploy this repo's `storage.rules`.

Profile image uploads currently use:

```text
images/{uid}
```

The storage rules allow authenticated users to read profile images and allow a
user to create, update, or delete only their own profile image. Uploads are
limited to image content under 5 MB.

## 12. Deploy Firestore and Storage rules

This repo contains:

```text
firebase.json
firestore.rules
storage.rules
```

Deploy both rule sets:

```bash
firebase deploy --only firestore:rules,storage
```

If the Firebase CLI asks you to select a project:

```bash
firebase use --add
firebase deploy --only firestore:rules,storage
```

Local validation:

```bash
firebase emulators:start --only firestore,storage
```

## 13. Seed admin food data

The app expects `indian_foods` to contain searchable food documents for calorie
logging. Use the admin screen only with a user whose Firestore document has:

```json
{
  "isAdmin": true
}
```

Set that field from Firebase Console or the Admin SDK. The mobile app rules
block normal users from granting themselves admin access.

## 14. Run and verify

Run the app:

```bash
flutter run
```

Verification commands:

```bash
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build apk --debug
```

Manual Firebase checks:

- Register a new email/password user.
- Confirm a verification email link is delivered.
- Try logging in before verification; the app should resend the link and block
  sign-in.
- Verify the email, then sign in successfully.
- Upload a profile photo and confirm it appears under `images/{uid}` in
  Firebase Storage.
- Confirm a non-admin user cannot write admin food collections.
- Confirm an admin user can seed `indian_foods`.

## 15. Common setup failures

### `firebase` command not found

Install the Firebase CLI:

```bash
npm install -g firebase-tools
```

Then restart the terminal and run:

```bash
firebase login
```

### `flutterfire` command not found

Install FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
```

Add Dart global executables to `PATH`:

```text
%LOCALAPPDATA%\Pub\Cache\bin
```

### Google Sign-In fails

Add debug and release SHA-1/SHA-256 fingerprints to the Android app in Firebase
Console, download a fresh `google-services.json`, and rerun:

```bash
flutterfire configure
```

### Firestore permission denied

Check:

- User is signed in.
- Rules were deployed.
- Reads and writes target the signed-in user's own documents.
- Admin-only writes are done by a user with `isAdmin == true`.
- `isAdmin` was set from Firebase Console or Admin SDK, not from the mobile app.

### Storage upload denied

Check:

- User is signed in.
- Upload path is exactly `images/{uid}`.
- `{uid}` matches `FirebaseAuth.instance.currentUser.uid`.
- File is an image.
- File size is under 5 MB.
- `storage.rules` was deployed.

### Email verification link not delivered

This is not an OTP. It is a Firebase email link. Check Authentication email
templates, spam folders, rate limits, project status, and network connectivity.
Then try signing in again so the app can resend the link.

### SMS OTP not delivered

Use Firebase Console test phone numbers first. If test numbers work but real
numbers do not, the issue is usually quota, region policy, carrier filtering,
device eligibility, missing SHA fingerprints, or Phone provider setup.
