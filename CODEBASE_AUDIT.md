# NutriTrack India Codebase Audit

Date: 2026-07-14

## Executive summary

The repository contains a substantial Flutter application (167 Dart files and
about 24,100 lines under `lib/`) with good owner-scoped Firestore rules and a
useful model/repository test base. Android and web now compile successfully, and
the web target now has a production PWA shell. The project is not yet ready for
an iOS release or an unattended production launch.

The main release blockers are missing iOS/Firebase setup, default `com.example`
store identifiers, incomplete account-data deletion, and unverified backend
controls around health data sent to the AI proxy. Web deployment also requires
a real Firebase Web app configuration; the repository now provides a safe
environment-specific configuration path but intentionally does not invent or
commit production values.

## Scope and verification

Reviewed:

- Application, model, repository, service, UI, routing, and legacy Dart code.
- Android, iOS, web, Firebase Hosting, Firestore, and Storage configuration.
- Dependency currency, secret exposure indicators, tests, responsive layout,
  platform-only APIs, authentication, account deletion, and AI/photo flows.

Verification completed:

- `flutter analyze --no-pub`: passes with no findings.
- `flutter test --no-pub`: all 29 tests pass.
- `flutter build web --release`: passes without the old bootstrap warning.
- `flutter build apk --debug --no-pub`: passes.
- PWA tests validate manifest identity, icon dimensions, bootstrap/worker
  registration, and Firebase Hosting SPA rules.
- A headless Chrome smoke test loaded the built app online, stopped the local
  server, then successfully rendered the same Flutter setup screen offline from
  the custom worker cache.
- `firebase.json` and `web/manifest.json` parse successfully.

Not verified:

- iOS compilation, signing, HealthKit, notifications, and store packaging;
  Apple builds require macOS/Xcode and the repository is missing required iOS
  setup files.
- A live Firebase web login/data session because no Firebase Web app values were
  provided.
- Firestore/Storage rules in the Firebase Emulator Suite; no rules tests exist.
- The external AI proxy implementation, token validation, retention, or rate
  limits because that backend is not in this repository.

## Changes completed during this audit

### Web/PWA

- Replaced the deprecated web bootstrap in `web/index.html`.
- Added a current `web/flutter_bootstrap.js` and custom `web/sw.js`.
- Added install metadata, theme colors, language, scope, and branded regular,
  maskable, Apple touch, and favicon assets.
- Added Firebase Hosting static hosting, SPA rewrites, MIME, and cache headers.
- Added an environment-specific Firebase Web configuration template and a
  user-visible initialization error instead of a blank screen.
- Added desktop `NavigationRail` behavior and a 1200 px content boundary.
- Reduced the forced splash delay from six seconds to 600 ms and added an
  offline-safe navigation fallback.
- Added PWA regression tests.

The custom service worker is deliberate. Current Flutter documentation states
that Flutter no longer generates or manages one by default, so PWA offline
support should not depend on the older generated worker:
[Flutter Web FAQ](https://docs.flutter.dev/platform-integration/web/faq).

### Cross-platform/runtime

- Guarded local notifications, Health Connect, and Android home-widget calls on
  web.
- Converted meal-photo, label-photo, and profile-photo operations from
  `dart:io File` uploads to browser-safe bytes.
- Removed the redundant temporary Firebase Storage upload from AI photo
  analysis; the image is now sent only to the configured proxy.
- Corrected the profile-image Storage path to match `storage.rules`.
- Added a browser AI fallback for nutrition-label recognition where ML Kit is
  unavailable.

### Android

- Updated compile/target SDK to 35, minimum SDK to 26, Android Gradle Plugin to
  8.6.1, and Gradle to 8.7 so the Health Connect dependency builds.
- Corrected Health Connect weight/hydration permissions and package visibility.
- Changed `MainActivity` to `FlutterFragmentActivity` for Android 14+ Health
  Connect permission results.
- Replaced exact alarms with inexact health reminders, removing an unnecessary
  sensitive alarm permission.

## Prioritized remaining findings

### P0 - release blockers

1. **iOS cannot start or build as checked in.**

   - `lib/firebase_options.dart` still rejects iOS because no Apple Firebase app
     is configured.
   - `ios/Runner/GoogleService-Info.plist` and `ios/Podfile` are absent.
   - No `.entitlements` file enables HealthKit or push notifications.
   - The Xcode deployment target is still iOS 9.0, below realistic requirements
     for the current Firebase/Health/plugin set.

   Register the iOS Firebase app, regenerate FlutterFire configuration, restore
   CocoaPods configuration, raise the deployment target based on the resolved
   plugins, add capabilities in Xcode, and validate on a real device.

2. **Store identities are placeholders.**

   Android uses `com.example.nutri_tracker`; iOS uses
   `com.example.nutriTracker`. These must be replaced with organization-owned,
   stable identifiers before Firebase app registration, signing, deep links,
   Health permissions review, or store submission. Versioning is also still
   `1.0.0+1`.

3. **Production web Firebase values are not present.**

   This is intentionally not guessed. Create a Firebase Web app, copy
   `config/firebase.web.example.json` to the ignored
   `config/firebase.web.json`, fill its values, configure authorized domains,
   and build with `--dart-define-from-file=config/firebase.web.json`.

### P1 - high priority

1. **Account deletion leaves personal data behind.**

   `lib/drawer/settings/delete_user.dart` deletes only a subset of collections.
   It does not recursively remove meal subcollections below daily calorie logs,
   workout logs/sessions, goals, workout programs, custom/recent/favourite
   foods, meal templates, daily summaries, or achievements. Firestore document
   deletion does not cascade into subcollections.

   Move deletion to a trusted backend using recursive delete semantics, make it
   idempotent, record completion, and add emulator tests. This is both a privacy
   and product-correctness issue.

2. **The external AI security/privacy boundary is unverified.**

   The client sends Firebase ID tokens, health profile context, chat content,
   and selected photos to a Remote Config URL. The backend must verify the ID
   token and audience, enforce App Check, rate-limit per user, restrict request
   size, prevent arbitrary model parameters, define retention/deletion, and
   avoid logging sensitive prompts/photos. None of that server code is in this
   checkout.

3. **Firebase App Check is absent.**

   Firestore rules provide good per-user isolation, but App Check should protect
   Firebase and proxy resources from scripted abuse using Play Integrity,
   App Attest/DeviceCheck, and a web attestation provider.

4. **PWA offline data needs an explicit privacy decision.**

   The service worker caches only the same-origin app shell/static assets. It
   does not cache Firebase responses. Firestore persistence on web remains off,
   so previously viewed health data is not guaranteed offline. Firebase warns
   that web persistence retains cached data between sessions and recommends a
   trusted-device decision for sensitive information:
   [Firestore offline persistence](https://firebase.google.com/docs/firestore/manage-data/enable-offline).

   Add an explicit trusted-device consent flow before enabling persistent
   Firestore caching.

5. **Web push notifications are not implemented.**

   Local scheduled notifications now degrade safely to no-ops on web. A PWA
   push feature needs Firebase Cloud Messaging (or another push service),
   notification permission UX, VAPID configuration, a messaging service worker,
   token lifecycle handling, and backend delivery. Health Connect and the
   Android home widget are also intentionally unavailable on web.

6. **Automated coverage is too narrow for release risk.**

   The 29 tests cover models and core repositories well, but there are no widget,
   golden, integration, auth, router, accessibility, rules-emulator, service
   worker browser, or end-to-end deletion tests. There is no CI workflow.

7. **Toolchain and dependency drift is large.**

   The local SDK is Flutter 3.24.5 while current Flutter documentation reflects
   Flutter 3.44. `flutter pub outdated` reports 44 dependencies constrained to
   older resolvable versions, including major Firebase, router, Riverpod,
   notification, scanner, and storage updates; several transitive packages are
   discontinued. Upgrade Flutter first on a dedicated branch, then upgrade
   related package families in stages with platform builds/tests after each.

### P2 - maintainability and UX

1. **Legacy/duplicate architecture is substantial.**

   A static import scan found 28 of 167 Dart files unreferenced, plus parallel
   `features/workout` and `features/workouts`, two BMI implementations, legacy
   homepage flows, unused repository interfaces/implementations, and duplicate
   route-era code. Large files (up to 851 lines) mix UI, Firebase, validation,
   and orchestration. Remove dead code only after coverage is added, then
   converge on one feature/repository structure.

2. **Web responsiveness is only partially addressed.**

   The shell now adapts to desktop widths, but many legacy/detail screens use
   fixed 350-500 px dimensions. Test phone, tablet, desktop, text scaling, zoom,
   landscape, keyboard-only input, and reduced-motion behavior.

3. **Accessibility validation is missing.**

   The code uses useful button tooltips in newer screens, but has no explicit
   `Semantics` usage and no accessibility tests. Validate labels, reading order,
   contrast, focus indicators, tap targets, and screen-reader announcements.

4. **Notification timezone defaults are unreliable.**

   `timezone` is initialized, but no device IANA timezone is assigned. Unless a
   user selects an override, `tz.local` can remain UTC and reminders can fire at
   the wrong local time. Add a maintained device-timezone integration and tests
   for daylight-saving changes.

5. **Lint policy hides useful risk signals.**

   `analysis_options.yaml` disables several correctness/style rules globally,
   including `use_build_context_synchronously`. Re-enable rules gradually and
   use narrow suppressions with explanations.

6. **Admin navigation is only backend-protected.**

   Any signed-in user can navigate to `/admin`; Firestore rules correctly block
   non-admin writes, but the router should also gate the screen on a trusted
   admin claim/profile state and show a clear forbidden page.

## Security positives

- Firestore rules consistently scope private data to `request.auth.uid` and
  prevent users from self-assigning `isAdmin`.
- Core nutrition/workout writes have sensible type and range validation.
- Storage writes are user-scoped, image-only, and limited to 5 MB.
- `.env` is ignored and has never been tracked in repository history.
- No Anthropic secret-value pattern was found in Git history; the client uses a
  proxy instead of embedding a model API key.

## Recommended release sequence

1. Choose permanent Android/iOS identifiers and create all Firebase apps.
2. Finish iOS CocoaPods, Firebase, HealthKit, notification, signing, and device
   validation on macOS.
3. Move recursive account deletion and AI enforcement to trusted backend code;
   add App Check and emulator/integration tests.
4. Supply the web Firebase config, verify auth providers/authorized domains,
   deploy to a staging HTTPS domain, and run browser install/offline/camera tests.
5. Add CI for analyze, tests, web build, Android app bundle, rules tests, and an
   iOS build on a macOS runner.
6. Upgrade Flutter/dependencies in staged groups, then remove dead code and
   tighten lint/accessibility coverage.
