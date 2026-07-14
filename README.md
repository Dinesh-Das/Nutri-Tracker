# NutriTrack India

NutriTrack India is a cross-platform Flutter nutrition and fitness application
designed around Indian meals. It combines food, hydration, weight, goal, and
workout tracking with Firebase-backed accounts, recipe discovery, and optional
AI-assisted nutrition features.

## Platform status

| Platform | Status | Notes |
| --- | --- | --- |
| Android | Builds | Debug build verified; release signing, production package ID, and store setup are still required. Minimum SDK is 26. |
| Web/PWA | Builds | Release build, install manifest, service worker, offline app shell, responsive navigation, and SPA hosting rules are present. A Firebase Web app configuration is required. |
| iOS | Setup required | The checked-in Xcode project is incomplete for release. Finish CocoaPods, Firebase, signing, capabilities, and deployment-target setup on macOS. |

See [CODEBASE_AUDIT.md](CODEBASE_AUDIT.md) for the full audit, completed fixes,
verification results, and remaining release blockers.

## Features

- Email/password, Google, email-verification, password-reset, and phone-OTP
  authentication flows
- Personal onboarding with BMI, BMR, calorie-goal, diet, and activity inputs
- Daily meal, calorie, macro, hydration, and weight tracking
- Barcode, nutrition-label, and meal-photo entry flows
- Indian food catalogue and TheMealDB recipe discovery
- Goals, streaks, achievements, progress charts, and workout programmes
- Health Connect integration and home-screen widget support on Android
- Meal reminder notifications
- NutriBot chat, nutrition estimation, and meal/workout planning through a
  server-side AI proxy
- Responsive Material 3 UI with dark and light themes
- Installable web PWA with an offline application shell

## Technology

- Flutter and Dart 3
- Riverpod for state management and `go_router` for navigation
- Firebase Authentication, Cloud Firestore, Storage, and Remote Config
- Hive, SharedPreferences, and secure local storage
- Dio for networking and TheMealDB for recipes
- `fl_chart`, Health Connect, local notifications, camera/scanner, and sharing
- Custom web manifest and service worker for PWA behaviour

## Project layout

```text
android/                 Android application and Gradle configuration
config/                  Ignored/local web Firebase config template
ios/                     iOS runner (requires completion before release)
lib/
  features/              Screens grouped by product area
  models/                Domain and Firestore models
  repositories/          Data-access abstractions and implementations
  router/                Shared GoRouter configuration
  services/              Firebase, health, AI, notification, and API services
test/                    Model, repository, service, and PWA regression tests
tool/                    Repeatable build utilities
web/                     PWA shell, manifest, icons, and service worker
```

Some legacy folders remain because older screens still import them. New work
should normally live under `lib/features`, `lib/repositories`, or
`lib/services`.

## Prerequisites

- Flutter stable with Dart `>=3.0.0 <4.0.0`
- Android Studio/Android SDK for Android development
- macOS with Xcode and CocoaPods for iOS development
- A Firebase project with the required platform apps registered
- Firebase CLI and FlutterFire CLI for Firebase configuration/deployment
- Node.js only when using the Vercel CLI or developing a JavaScript backend

Confirm the local toolchain before continuing:

```bash
flutter doctor
flutter --version
```

## Quick start

Install packages:

```bash
flutter pub get
```

Run Android using the checked-in Android Firebase configuration:

```bash
flutter run -d <android-device-id>
```

For web, first create the ignored configuration file:

```powershell
Copy-Item config/firebase.web.example.json config/firebase.web.json
```

On macOS/Linux:

```bash
cp config/firebase.web.example.json config/firebase.web.json
```

Fill it with the Web app values from Firebase Console, then run:

```bash
flutter run -d chrome --dart-define-from-file=config/firebase.web.json
```

The file is intentionally ignored by Git. `tool/build_web.dart` can read the
same file or equivalent environment variables for automated deployments.

## Firebase setup

The app expects Authentication, Cloud Firestore, Storage, and Remote Config.
The complete platform-registration, SHA fingerprint, security-rule, OTP, and
admin setup is documented in [FIREBASE_SETUP.md](FIREBASE_SETUP.md).

At minimum:

1. Register separate Android, iOS, and Web apps in Firebase.
2. Run `flutterfire configure` for native platforms and add the generated
   platform files to the correct runner targets.
3. Enable the authentication providers used by the app.
4. Create Firestore and Storage, then deploy the checked-in rules.
5. Add every deployed web domain to Firebase Authentication's authorized
   domains.

Deploy security rules:

```bash
firebase deploy --only firestore:rules,storage
```

The main Firestore paths are:

```text
user_details/{uid}
user_details/{uid}/favourites/{itemId}
user_details/{uid}/mealPlans/{planId}
calorie_logs/{uid}/daily/{YYYY-MM-DD}
weight_logs/{uid}/entries/{docId}
indian_foods/{docId}
food_data/{docId}
ai_chats/{uid}/messages/{docId}
```

Admin access is controlled by `user_details/{uid}.isAdmin == true`. Set this
only through Firebase Console or a trusted Admin SDK environment.

## NutriBot configuration

NutriBot reads the `nutribot_proxy_url` Remote Config key. Its value must be an
HTTPS backend that:

- verifies the caller's Firebase ID token;
- keeps the model-provider API key on the server;
- validates input and output;
- rate-limits requests; and
- applies an explicit retention policy for health-related data.

Never put an Anthropic/OpenAI key in Dart source, Flutter assets, Firebase Web
configuration, or a Vercel variable that is compiled into the web bundle.

## Build commands

Android App Bundle:

```bash
flutter build appbundle --release
```

Web release bundle:

```bash
flutter build web --release \
  --dart-define-from-file=config/firebase.web.json
```

Equivalent deployment-friendly web build:

```bash
dart run tool/build_web.dart
```

iOS, after completing the setup described in the audit and Firebase guide:

```bash
flutter build ios --release
```

## PWA and web deployment

The web target contains:

- a production manifest with regular and maskable install icons;
- a root-scoped service worker;
- an offline application-shell cache;
- network-first navigation and JavaScript updates; and
- SPA rewrites plus update-safe cache headers for Firebase Hosting and Vercel.

Firebase/API responses and user health records are not added to the custom
service-worker cache. Firestore persistent web caching should only be enabled
after adding an explicit trusted-device consent flow.

For Vercel, follow [VERCEL_DEPLOYMENT.md](VERCEL_DEPLOYMENT.md). For Firebase
Hosting:

```bash
flutter build web --release \
  --dart-define-from-file=config/firebase.web.json
firebase deploy --only hosting
```

## Quality checks

Run these before opening a pull request or producing a release:

```bash
flutter analyze --no-pub
flutter test --no-pub
flutter build web --release --dart-define-from-file=config/firebase.web.json
flutter build apk --debug --no-pub
```

The current verification records a clean analyzer run, 29 passing tests, a
successful web release build, a successful Android debug APK, and a browser
online/offline PWA smoke test.

## Additional documentation

- [CODEBASE_AUDIT.md](CODEBASE_AUDIT.md) — architecture and release-readiness audit
- [FIREBASE_SETUP.md](FIREBASE_SETUP.md) — Firebase and authentication setup
- [VERCEL_DEPLOYMENT.md](VERCEL_DEPLOYMENT.md) — Vercel preview/production deployment
- [firestore_config.md](firestore_config.md) — Firestore data notes

## Security and release notes

- This app handles nutrition and health-related information. Review consent,
  privacy, deletion, retention, logging, and regional compliance requirements
  before launch.
- Replace the default `com.example.nutri_tracker` identifier before publishing.
- Complete the account-data deletion flow and validate the AI proxy controls.
- Do not ship Firebase Admin credentials or model-provider secrets in a client.
- Rotate the service-worker cache name in `web/sw.js` when changing its cache
  strategy or when an urgent cache invalidation is needed.

## License

No open-source licence has been declared for this repository. Add a `LICENSE`
file before distributing the source publicly.
