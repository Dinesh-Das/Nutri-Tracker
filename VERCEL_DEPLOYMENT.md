# Deploy the Flutter PWA to Vercel

This guide deploys NutriTrack as a static Flutter web application on Vercel.
Firebase remains the backend for authentication, data, storage, and Remote
Config; Vercel serves only the compiled PWA files.

## Deployment model

Flutter is not an auto-detected Vercel framework preset, so this repository uses
Vercel's **Other** framework mode and a custom build command. Run the build on a
machine or CI runner that has Flutter installed, then upload Vercel's prebuilt
output:

```text
Firebase/Vercel variables
          |
          v
dart run tool/build_web.dart
          |
          v
       build/web
          |
          v
      vercel build
          |
          v
   .vercel/output
          |
          v
vercel deploy --prebuilt
```

The checked-in `vercel.json` configures:

- `dart run tool/build_web.dart` as the build command;
- `build/web` as the static output directory;
- a catch-all rewrite to `index.html` for Flutter/GoRouter deep links; and
- PWA cache headers that let `index.html`, the bootstrap, manifest, and service
  worker update safely.

## Prerequisites

- A Vercel account and project
- Flutter available on `PATH`
- Node.js and the Vercel CLI
- A registered Firebase Web app
- Permission to add the deployed domain in Firebase Authentication

Install and authenticate the CLI:

```bash
npm install --global vercel@latest
vercel login
```

## 1. Link the project

Run this from the repository root:

```bash
vercel link
```

Choose an existing Vercel project or create one. Keep the root directory as the
repository root. The framework should resolve to **Other**; the checked-in
`vercel.json` supplies the remaining build settings.

Vercel writes local project metadata under `.vercel/`. That directory is
ignored by Git.

## 2. Add Firebase Web variables

In Vercel, open **Project Settings > Environment Variables** and add the values
from Firebase Console's Web app configuration.

| Variable | Required | Firebase field |
| --- | --- | --- |
| `FIREBASE_WEB_API_KEY` | Yes | `apiKey` |
| `FIREBASE_WEB_APP_ID` | Yes | `appId` |
| `FIREBASE_WEB_MESSAGING_SENDER_ID` | Yes | `messagingSenderId` |
| `FIREBASE_WEB_PROJECT_ID` | Yes | `projectId` |
| `FIREBASE_WEB_AUTH_DOMAIN` | Recommended | `authDomain` |
| `FIREBASE_WEB_STORAGE_BUCKET` | Recommended | `storageBucket` |
| `FIREBASE_WEB_MEASUREMENT_ID` | Optional | `measurementId` |

Apply the variables to both **Preview** and **Production** if both environments
will be used. Values can also be added interactively with:

```bash
vercel env add FIREBASE_WEB_API_KEY production
vercel env add FIREBASE_WEB_API_KEY preview
```

Repeat that command for each variable.

Firebase Web configuration identifies the Firebase project and is compiled into
`main.dart.js`; it is not a server-side secret. Access must still be protected
with Firebase Authentication, App Check where appropriate, and deployed
Firestore/Storage rules. Never put an AI provider key or Firebase Admin
credential in these variables.

## 3. Create a preview deployment

Pull Preview settings, build locally with Flutter, and upload the prebuilt
result:

```bash
vercel pull --yes --environment=preview
vercel build
vercel deploy --prebuilt --archive=tgz
```

`vercel pull` makes the selected environment's project settings and variables
available to `vercel build`. The repository's Dart wrapper fails early if any
of the four required Firebase values are missing.

Open the generated preview URL and complete the checks below before promoting a
production deployment.

## 4. Create a production deployment

```bash
vercel pull --yes --environment=production
vercel build --prod
vercel deploy --prebuilt --prod --archive=tgz
```

Any change to Vercel environment variables requires a new build and deployment;
the values are compile-time inputs to Flutter rather than runtime server
configuration.

## 5. Authorize the deployed domain in Firebase

In **Firebase Console > Authentication > Settings > Authorized domains**, add:

- the production `your-project.vercel.app` domain;
- every custom domain; and
- preview domains only when authentication testing on previews is required.

Also verify provider-specific configuration, such as Google OAuth origins and
phone-auth requirements. An otherwise healthy deployment can still fail sign-in
with `auth/unauthorized-domain` until this step is complete.

## 6. Add a custom domain

Add the domain in **Vercel Project Settings > Domains** and follow the displayed
DNS instructions. After Vercel provisions HTTPS, add the same host to Firebase
Authentication's authorized domains and retest every enabled sign-in provider.

No PWA installation is offered from an insecure HTTP origin; production and
preview URLs must remain on HTTPS.

## Verification checklist

Use a fresh browser profile or clear site data, then verify:

- the root URL loads without a Firebase setup error;
- refreshing a nested application route does not return a Vercel 404;
- sign-up, sign-in, sign-out, and password reset work;
- Firestore and Storage requests are accepted only for authorized users;
- Chrome/Edge DevTools **Application > Manifest** shows no errors;
- the 192 px and 512 px regular and maskable icons load;
- `sw.js` is registered with `/` scope;
- the app becomes installable; and
- after one successful online load, the application shell starts offline.

Do not interpret the offline shell as offline data support. Firebase requests
still require connectivity because persistent Firestore web caching is not
enabled by default for this health-data application.

## Continuous deployment

A direct Vercel Git import will run its build on Vercel's build image. This
repository deliberately does not depend on Flutter being preinstalled there.
For automated deployments, use a CI runner that installs Flutter and performs
the same prebuilt sequence:

1. Check out the repository.
2. Install the project's Flutter/Dart version and run `flutter pub get`.
3. Install `vercel@latest`.
4. Expose `VERCEL_TOKEN`, `VERCEL_ORG_ID`, and `VERCEL_PROJECT_ID` as protected
   CI secrets.
5. Run `vercel pull` for the intended environment.
6. Run `vercel build` (add `--prod` for production).
7. Run `vercel deploy --prebuilt` (add `--prod` for production).

Protect production deployment jobs with branch and environment approval rules.
Do not commit `.vercel/`, `.env.local`, `config/firebase.web.json`, or CI tokens.

## Local build without Vercel variables

For development, copy and fill the ignored config file:

```powershell
Copy-Item config/firebase.web.example.json config/firebase.web.json
dart run tool/build_web.dart
```

On macOS/Linux:

```bash
cp config/firebase.web.example.json config/firebase.web.json
dart run tool/build_web.dart
```

Environment variables take precedence over the JSON file, so CI can override
local values without rewriting it.

## Troubleshooting

### `Missing required Firebase Web build variables`

At least one required Vercel variable is absent from the selected environment.
Check `vercel env ls`, update the variable, rerun `vercel pull`, and rebuild.

### `dart` or `flutter` is not found

The build is running on a machine without Flutter on `PATH`. Use the prebuilt
workflow on a configured developer machine or install Flutter in the CI job.

### A nested route returns 404

Confirm the deployment used the repository-root `vercel.json`. The SPA rewrite
must be present in the deployed project, and Vercel's Output Directory must be
`build/web`.

### Firebase shows a setup screen

The deployment was built without the required Firebase variables. Adding them
afterward does not modify an existing `main.dart.js`; rebuild and redeploy.

### Authentication reports `unauthorized-domain`

Add the exact Vercel or custom host to Firebase Authentication's authorized
domains. Preview deployments use different hosts from production.

### An old PWA remains after deployment

First close every open app tab, reopen the site online, and allow the new worker
to activate. For a deliberate cache-strategy change or emergency invalidation,
increment `CACHE_NAME` in `web/sw.js`, rebuild, and redeploy. DevTools can also
unregister the worker and clear site storage during testing.

### Service worker or manifest has the wrong content type/cache policy

Verify the response headers for `/sw.js`, `/manifest.json`, `/index.html`, and
`/flutter_bootstrap.js`. They are declared in `vercel.json`; a dashboard-level
override or deployment from the wrong root can bypass that file.

## Official Vercel references

- [Configure a build](https://vercel.com/docs/builds/configure-a-build)
- [Project configuration with `vercel.json`](https://vercel.com/docs/project-configuration/vercel-json)
- [Deploy a project from the CLI](https://vercel.com/docs/projects/deploy-from-cli)
- [Vercel CLI prebuilt deployments](https://vercel.com/docs/cli/deploy)
- [Environment variables](https://vercel.com/docs/environment-variables)
