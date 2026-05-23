# NutriTrack India

NutriTrack India is a Flutter + Firebase nutrition and health tracking app focused on Indian food habits. It includes BMI monitoring, calorie and water logging, Indian recipe discovery through TheMealDB, progress charts, favourites, local meal reminders, an admin food database, and an AI nutrition assistant powered by Claude.

> Security note: the old README contained a GitHub personal access token. It has been removed. Revoke that token in GitHub immediately if it was ever valid, because committed tokens should be treated as compromised.

## Features

- Email/password and Google authentication with Firebase Auth
- First-run onboarding for height, weight, goal, diet preference, and activity level
- 5-tab app shell: Home, Log, Recipes, Progress, NutriBot
- Dashboard with calories, macros, water, BMI status, food recommendations, quote, and featured Indian recipe
- Calorie logger backed by Firestore `indian_foods`
- Water tracker persisted per day
- BMI calculator that saves profile BMI and weight history
- Progress charts using `fl_chart`
- Indian recipe feed from TheMealDB, no API key required
- Recipe detail, sharing, and favourites
- AI NutriBot chat using Anthropic Claude Messages API
- AI nutrition estimator and meal plan generator
- Admin panel with Firestore `isAdmin` access check
- Indian food seeder with 50 common foods
- Local meal reminder notifications
- Dark/light Material 3 theme

## Tech Stack

- Flutter 3.x / Dart 3
- Firebase Core, Auth, Firestore, Storage
- Provider for existing app state
- Riverpod dependency added for future feature state
- Firestore as primary app database
- TheMealDB for recipes
- Anthropic Claude API for AI nutrition features
- `flutter_local_notifications` for reminders

## Project Structure

```text
lib/
  main.dart
  firebase_options.dart
  routes/
  themes/
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

The app still keeps some legacy folders (`database`, `drawer`, `homepage`, `onbparding_components`) so older working screens and imports do not break while the newer feature modules live under `lib/features`.

## Prerequisites

Install:

- Flutter SDK 3.x
- Dart 3.x
- Android Studio or Android command-line tools
- Firebase CLI
- FlutterFire CLI
- A Firebase project
- An Anthropic API key for NutriBot

Check Flutter:

```bash
flutter doctor
flutter --version
```

This repository was verified locally with:

```text
Flutter 3.24.5
Dart 3.5.4
```

## Environment Variables

Create a `.env` file in the project root:

```env
ANTHROPIC_API_KEY=your_anthropic_api_key_here
```

`.env` is intentionally ignored by git. Do not commit API keys.

## Install Dependencies

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## Firebase Configuration Process

### 1. Create Firebase Project

1. Open the Firebase Console.
2. Create a new project, for example `nutritrack-india`.
3. Enable Google Analytics if desired.
4. Open Project Settings after the project is created.

### 2. Add Android App

Use the existing package name:

```text
com.example.nutri_tracker
```

Steps:

1. In Firebase Project Settings, click Add app.
2. Select Android.
3. Enter package name `com.example.nutri_tracker`.
4. Enter app nickname, for example `NutriTrack India Android`.
5. Register the app.

For Google Sign-In, add SHA fingerprints:

```bash
cd android
./gradlew signingReport
```

On Windows PowerShell:

```powershell
cd android
.\gradlew signingReport
```

Copy the debug SHA-1 and SHA-256 into Firebase Project Settings under the Android app.

### 3. Add iOS App

If building iOS, add an iOS app in Firebase with the bundle ID used by your iOS project. Then run FlutterFire configuration again so `lib/firebase_options.dart` contains real iOS values.

### 4. Install Firebase and FlutterFire CLIs

```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

Log in:

```bash
firebase login
```

Make sure Dart global binaries are on your PATH. On Windows this is usually:

```text
%LOCALAPPDATA%\Pub\Cache\bin
```

### 5. Generate Firebase Options

From the project root:

```bash
flutterfire configure
```

Select:

- Your Firebase project
- Android
- iOS if needed
- Web if needed

This regenerates:

```text
lib/firebase_options.dart
```

The app initializes Firebase in `lib/main.dart` with:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### 6. Enable Firebase Products

In Firebase Console, enable:

- Authentication
- Cloud Firestore
- Firebase Storage

Authentication providers:

- Email/Password
- Google

Firestore:

- Create a database.
- Start in production mode.
- Deploy the rules in this repo.

Storage:

- Create the default bucket.
- Use Firebase Storage for profile image uploads.

### 7. Deploy Firestore Rules

The rules file is:

```text
firestore.rules
```

Initialize Firebase hosting/config files if this project is not yet linked:

```bash
firebase init firestore
```

When prompted:

- Select the Firebase project.
- Use `firestore.rules` for rules.
- Use the default indexes file or create `firestore.indexes.json`.

Deploy rules:

```bash
firebase deploy --only firestore:rules
```

### 8. Firestore Collections

The app expects these collections:

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

### 9. Admin Access

Admin access is controlled by Firestore:

```text
user_details/{uid}.isAdmin == true
```

To make a user an admin, manually update their Firestore document:

```json
{
  "isAdmin": true
}
```

Do not use email checks or SharedPreferences for admin access.

### 10. Seed Indian Foods

After signing in as an admin:

1. Open the Admin Panel.
2. Go to Indian Foods.
3. Tap Seed 50 Indian Foods.

This writes common Indian foods such as dal makhani, rajma chawal, idli, dosa, poha, biryani, paneer dishes, chaas, lassi, chai, and more to:

```text
indian_foods
```

The calorie logger searches this collection.

## Android Configuration

The package name is kept as:

```text
com.example.nutri_tracker
```

Current Android settings:

```gradle
compileSdkVersion 34
minSdkVersion 23
targetSdkVersion 34
```

Firebase Auth currently requires `minSdkVersion 23`, so the project uses 23 even though the original target was 21.

The Android app label is:

```text
NutriTrack India
```

Notification permission is included for Android 13+:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

## Anthropic / NutriBot Configuration

NutriBot calls the Claude Messages API directly:

```text
https://api.anthropic.com/v1/messages
```

Model:

```text
claude-sonnet-4-20250514
```

Required header:

```text
anthropic-version: 2023-06-01
```

Set your API key in `.env`:

```env
ANTHROPIC_API_KEY=your_key
```

If the key is missing, NutriBot shows a friendly failure message instead of crashing.

## TheMealDB Recipe API

The app uses TheMealDB and does not need a key.

Endpoints used:

```text
https://www.themealdb.com/api/json/v1/1/filter.php?a=Indian
https://www.themealdb.com/api/json/v1/1/search.php?s={query}
https://www.themealdb.com/api/json/v1/1/lookup.php?i={id}
```

## Run the App

```bash
flutter run
```

Build debug APK:

```bash
flutter build apk --debug
```

The debug APK is generated at:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Verification Commands

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter build apk --debug
```

The legacy codebase still has many lint warnings and info messages, mostly naming/style issues from older files. The app currently compiles with the non-fatal analyzer mode above.

## Manual Test Checklist

### Auth

- Register with email/password
- Confirm email verification flow
- Login with email/password
- Login with Google
- Forgot password sends reset email
- Logout returns to login/onboarding flow

### Onboarding

- Appears for new users
- Saves height, weight, gender, activity level, diet preference, and goal
- Calculates BMI, BMR, and daily calorie goal
- Skips onboarding after completion

### Dashboard

- Shows greeting, date, calories, macros, water, BMI, quote, and recipe
- Opens calorie logger, BMI calculator, and NutriBot from quick actions
- Shows food recommendations after `indian_foods` is seeded

### Calorie Logger

- Date navigation works
- Indian food search returns Firestore foods
- Adding food updates calories and macros
- Water tracker persists

### Recipes

- Indian recipes load from TheMealDB
- Search works
- Recipe detail shows image, ingredients, and steps
- Save to favourites works
- Share works

### Progress

- BMI chart handles no data
- Weight chart handles no data
- Weekly calorie chart handles no logs
- Macro pie chart handles empty data

### AI

- `.env` contains `ANTHROPIC_API_KEY`
- NutriBot replies
- Nutrition estimator parses JSON
- Meal plan generator returns a plan
- API failures show friendly messages

### Admin

- User with `isAdmin == true` can access Admin Panel
- Admin can add foods
- Admin can seed Indian foods
- Non-admin users cannot write protected collections

### Notifications

- Settings toggles schedule/cancel reminders
- Android notification permission is granted on Android 13+

## Troubleshooting

### `Missing ANTHROPIC_API_KEY`

Create `.env` in the project root and add:

```env
ANTHROPIC_API_KEY=your_key
```

Then restart the app.

### Firebase app not configured

Regenerate Firebase options:

```bash
flutterfire configure
flutter pub get
```

Confirm `lib/firebase_options.dart` exists and `main.dart` uses `DefaultFirebaseOptions.currentPlatform`.

### Google Sign-In fails on Android

Add SHA-1 and SHA-256 fingerprints to the Android app in Firebase Console, then download/update Firebase config or rerun:

```bash
flutterfire configure
```

### Firestore permission denied

Check:

- User is signed in
- Firestore rules are deployed
- Admin writes are only attempted by users with `isAdmin == true`
- User-specific documents use the authenticated user's UID

### Android build minSdk issue

Firebase Auth requires min SDK 23 in this setup. Keep:

```gradle
minSdkVersion 23
```

### Kotlin daemon different roots warning

If Gradle shows a Kotlin daemon message about different roots but still builds the APK, it can be ignored. If it fails, clean and rebuild:

```bash
flutter clean
flutter pub get
flutter build apk --debug
```

## Notes for Contributors

- Keep API keys out of git.
- Use `MaterialPageRoute` for new navigation unless a router migration is done in one pass.
- Preserve existing Firestore fields in `UserModel`.
- Keep `food_data` and `indian_foods` as separate collections.
- Prefer adding new production features under `lib/features`.
- Deploy Firestore rules whenever collection access changes.
