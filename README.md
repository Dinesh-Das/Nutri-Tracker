# NutriTrack India

NutriTrack India is a Flutter 3 + Firebase nutrition app focused on Indian eating patterns. It supports Firebase Auth, onboarding, BMI and BMR tracking, calorie and water logging, Indian recipe discovery from TheMealDB, progress charts, favourites, admin-managed Indian food data, local meal reminders, and NutriBot AI nutrition features through a secure backend proxy.

## Features

- Email/password auth, Google Sign-In, forgot password, and Firebase email verification
- First-run onboarding for age, height, weight, gender, diet preference, goal, and activity level
- Five bottom tabs: Home, Log, Recipes, Progress, NutriBot
- Dashboard with calorie progress, macro chart, water tracker, BMI gauge, recommended foods, quote, and featured recipe
- Calorie logger backed by Firestore `indian_foods`
- Water tracker persisted in daily calorie logs
- BMI calculator that saves profile BMI and weight history
- Progress charts for BMI, weight, weekly calories, macros, and log streak
- Indian recipe feed from TheMealDB, no API key required
- Recipe detail, sharing, and favourites
- NutriBot AI chat, nutrition estimator, and meal plan generator
- Firestore-secured admin panel and Indian food seeder
- Local meal reminder notifications
- Dark/light Material 3 theme

## Tech Stack

- Flutter 3.x and Dart 3
- Firebase Core, Auth, Firestore, Storage
- Provider for existing app state
- Firestore as the primary database
- TheMealDB for Indian recipes
- Secure AI proxy for Anthropic Claude Messages API
- `flutter_local_notifications` for meal reminders
- `fl_chart` and `percent_indicator` for health visualizations

## Project Structure

```text
lib/
  main.dart
  firebase_options.dart
  routes/
  models/
  services/
  features/
    ai/
    calories/
    favourites/
    home/
    onboarding/
    progress/
    recipes/
  widgets/
  admin/
  database/
  drawer/
  homepage/
```

Some legacy folders remain intentionally (`database`, `drawer`, `homepage`, `onbparding_components`) because older working screens still import them.

## Prerequisites

Install:

- Flutter SDK 3.x
- Dart 3.x
- Android Studio or Android command-line tools
- Firebase CLI
- FlutterFire CLI
- Node.js if you plan to deploy Firebase Functions for NutriBot

Check your local setup:

```bash
flutter doctor
flutter --version
```

## Install Dependencies

From the project root:

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

The second command is only needed when Hive-generated files are introduced or changed. It is safe to run.

## Firebase Configuration Process

### 1. Create a Firebase Project

1. Open the Firebase Console.
2. Create a project, for example `nutritrack-india`.
3. Open Project Settings after creation.

### 2. Add the Android App

Use the existing Android package name:

```text
com.example.nutri_tracker
```

Steps:

1. In Firebase Project Settings, select Add app.
2. Choose Android.
3. Enter `com.example.nutri_tracker`.
4. Register the app.

For Google Sign-In, add debug SHA fingerprints.

PowerShell:

```powershell
cd android
.\gradlew signingReport
```

Bash:

```bash
cd android
./gradlew signingReport
```

Copy the SHA-1 and SHA-256 values into the Android app settings in Firebase Console.

### 3. Install Firebase CLI and FlutterFire CLI

```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
firebase login
```

On Windows, make sure Dart global binaries are on PATH:

```text
%LOCALAPPDATA%\Pub\Cache\bin
```

### 4. Generate `firebase_options.dart`

From the project root:

```bash
flutterfire configure
```

Select:

- Your Firebase project
- Android
- iOS and web only if you have real app registrations for those platforms

This regenerates:

```text
lib/firebase_options.dart
```

Current checked-in Firebase options are Android-only. iOS, web, macOS, Windows, and Linux intentionally throw an unsupported-platform error until you run `flutterfire configure` with real platform values.

Firebase initializes in [lib/main.dart](lib/main.dart):

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### 5. Enable Firebase Products

In Firebase Console, enable:

- Authentication
- Cloud Firestore
- Firebase Storage

Authentication providers:

- Email/Password
- Google

Firestore:

- Create a database.
- Use production mode.
- Deploy this repo's rules.

Storage:

- Create the default bucket.
- Use it for profile image uploads.

### 6. Deploy Firestore Rules

Rules live in:

```text
firestore.rules
```

Initialize Firestore config if needed:

```bash
firebase init firestore
```

Deploy:

```bash
firebase deploy --only firestore:rules
```

Important rule behavior:

- Users can read and update only their own `user_details/{uid}` document.
- Users cannot create or modify `isAdmin` from the mobile app.
- Admin-only writes to `food_data` and `indian_foods` require `user_details/{uid}.isAdmin == true`.
- AI chat messages are private per user and only allow `user` or `assistant` roles.

### 7. Firestore Collections

The app expects:

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

### 8. Grant Admin Access

Admin access is controlled by Firestore:

```text
user_details/{uid}.isAdmin == true
```

Set this only from Firebase Console, Admin SDK, or a trusted backend. Do not set it from the mobile app.

Example admin field:

```json
{
  "isAdmin": true
}
```

### 9. Seed Indian Foods

After signing in as an admin:

1. Open Admin Panel.
2. Open Indian Foods.
3. Tap Seed 50 Indian Foods.

This writes common foods such as dal makhani, rajma chawal, chole, idli, dosa, poha, biryani, paneer dishes, chaas, lassi, chai, nimbu pani, and more to:

```text
indian_foods
```

The calorie logger searches this collection.

## Secure NutriBot AI Configuration

The Flutter app must not contain an Anthropic API key. Mobile apps can be decompiled, so keys shipped through `.env`, assets, or source code are not secret.

NutriBot now calls a secure proxy URL supplied at runtime:

```text
NUTRIBOT_PROXY_URL
```

Run with:

```bash
flutter run --dart-define=NUTRIBOT_PROXY_URL=https://your-domain.example.com/messages
```

Debug APK with proxy:

```bash
flutter build apk --debug --dart-define=NUTRIBOT_PROXY_URL=https://your-domain.example.com/messages
```

If no proxy URL is supplied, the app still runs, but NutriBot, nutrition estimation, and meal plan generation show a friendly configuration error.

### Expected Proxy Contract

The app sends a POST request to `NUTRIBOT_PROXY_URL` with this JSON shape:

```json
{
  "model": "claude-sonnet-4-20250514",
  "max_tokens": 1024,
  "system": "NutriBot system prompt plus user context",
  "messages": [
    {"role": "user", "content": "What should I eat today?"}
  ]
}
```

Your proxy should:

1. Read the Anthropic API key from a server-side secret.
2. Forward the request to `https://api.anthropic.com/v1/messages`.
3. Set headers:

```text
Content-Type: application/json
x-api-key: YOUR_SERVER_SIDE_ANTHROPIC_KEY
anthropic-version: 2023-06-01
```

4. Return either the normal Anthropic response or a simplified response:

```json
{
  "text": "Assistant response text"
}
```

Firebase Functions is a good place to host this proxy. Store the key with Firebase Functions secrets or environment config, never in Flutter assets.

## TheMealDB Recipe API

TheMealDB does not require an API key.

Endpoints used:

```text
https://www.themealdb.com/api/json/v1/1/filter.php?a=Indian
https://www.themealdb.com/api/json/v1/1/search.php?s={query}
https://www.themealdb.com/api/json/v1/1/lookup.php?i={id}
```

The legacy Yummly/RapidAPI integration has been removed from executable code.

## Android Configuration

Package name:

```text
com.example.nutri_tracker
```

Current Gradle settings:

```gradle
compileSdkVersion 34
minSdkVersion 23
targetSdkVersion 34
```

Android permissions include notification scheduling support:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

App label:

```text
NutriTrack India
```

## How to Run

### Run on Android Device or Emulator

```bash
flutter pub get
flutter run
```

With NutriBot enabled:

```bash
flutter run --dart-define=NUTRIBOT_PROXY_URL=https://your-domain.example.com/messages
```

### Build Debug APK

```bash
flutter build apk --debug
```

With NutriBot enabled:

```bash
flutter build apk --debug --dart-define=NUTRIBOT_PROXY_URL=https://your-domain.example.com/messages
```

APK output:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

### Clean Rebuild

```bash
flutter clean
flutter pub get
flutter build apk --debug
```

## Verification Commands

```bash
flutter pub get
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build apk --debug
```

The codebase still has many legacy lint warnings from older files, mostly naming and style issues. The commands above verify that there are no blocking analyzer errors, tests pass, and the Android debug build compiles.

## Manual Test Checklist

### Auth

- Register with email/password.
- Confirm Firebase sends an email verification message.
- Log in with email/password.
- Log in with Google after adding SHA fingerprints.
- Forgot password sends reset email.
- Logout returns to login/onboarding flow.

### Onboarding

- Appears for new users.
- Saves height, weight, gender, activity level, diet preference, and goal.
- Calculates BMI, BMR, and daily calorie goal.
- Skips onboarding after completion.

### Dashboard

- Shows greeting, date, calories, macros, water, BMI, quote, and featured recipe.
- Opens calorie logger, BMI calculator, and NutriBot from quick actions.
- Shows food recommendations after `indian_foods` is seeded.

### Calorie Logger

- Date navigation works.
- Indian food search returns Firestore foods.
- Adding food updates calories and macros.
- Water tracker persists and can fill/unfill cups.

### Recipes

- Indian recipes load from TheMealDB.
- Search works.
- Recipe detail shows image, ingredients, and steps.
- Save to favourites persists in Firestore.
- Share works.

### Progress

- BMI chart handles no data.
- Weight chart handles no data.
- Weekly calorie chart handles no logs.
- Macro chart handles empty data.
- Log streak reflects consecutive logged days.

### AI

- App is run with `NUTRIBOT_PROXY_URL`.
- Proxy has the Anthropic key server-side.
- NutriBot replies.
- Nutrition estimator parses JSON.
- Meal plan generator returns a plan or shows a friendly error.

### Admin

- Non-admin users cannot open the admin panel UI.
- Non-admin users cannot write `food_data` or `indian_foods`.
- User with `isAdmin == true` can access Admin Panel.
- Admin can add existing `food_data` items.
- Admin can seed and add `indian_foods`.

### Notifications

- Android notification permission is requested on Android 13+.
- Settings toggles schedule/cancel reminders.
- Breakfast, lunch, and dinner reminders schedule daily.

## Troubleshooting

### Firebase app not configured

Run:

```bash
flutterfire configure
flutter pub get
```

Confirm `lib/firebase_options.dart` exists and contains real values for your target platform.

### Unsupported Firebase platform

The checked-in config is Android-only. Run `flutterfire configure` and select iOS/web if you need those platforms.

### Google Sign-In fails on Android

Add SHA-1 and SHA-256 fingerprints to Firebase Console, then rerun:

```bash
flutterfire configure
```

### Firestore permission denied

Check:

- User is signed in.
- Firestore rules are deployed.
- User documents contain `uid` equal to the Firebase Auth UID.
- Admin writes are only attempted by users with `isAdmin == true`.
- `isAdmin` was set from Console/Admin SDK, not from the mobile app.

### NutriBot is not configured

Run with a secure proxy URL:

```bash
flutter run --dart-define=NUTRIBOT_PROXY_URL=https://your-domain.example.com/messages
```

Do not add Anthropic keys to Flutter assets or source code.

### Kotlin daemon different roots warning

If Gradle prints a Kotlin daemon warning but still builds, it can usually be ignored. If the build fails:

```bash
flutter clean
flutter pub get
flutter build apk --debug
```

## Notes for Contributors

- Keep secrets out of git and out of Flutter assets.
- Deploy Firestore rules whenever collection access changes.
- Preserve existing `UserModel` fields.
- Keep `food_data` and `indian_foods` as separate collections.
- Prefer new production features under `lib/features`.
- Use TheMealDB for recipes; do not reintroduce Yummly/RapidAPI.
- Use `MaterialPageRoute` unless the app is migrated to a router in one pass.
