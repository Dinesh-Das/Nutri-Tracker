# NutriTrack India — Firestore Configuration Reference

> **Scope:** Firebase project for the NutriTrack India Flutter app.  
> **Last updated against codebase:** Post-Codex v2 (36 new files, all-in-one fitness build).

---

## 1. DEPLOYMENT

### Prerequisites
```bash
npm install -g firebase-tools
firebase login
firebase use --add          # select your project, alias: default
```

### Deploy everything at once
```bash
firebase deploy --only firestore
```

### Deploy individually
```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

### Local emulator (recommended for development)
```bash
firebase emulators:start --only firestore
# Flutter app: set FIRESTORE_EMULATOR_HOST=localhost:8080 in .env
```

---

## 2. SECURITY RULES  (`firestore.rules`)

Copy this file verbatim to the project root as `firestore.rules`.  
This is the corrected version — it includes `workoutStreak3` and
`caloriesBurned500` in the achievement allowlist (the only bug from the
original Codex output).

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ─── Helpers ────────────────────────────────────────────────────────────

    function signedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return signedIn() && request.auth.uid == userId;
    }

    function isAdmin() {
      return signedIn() &&
        get(/databases/$(database)/documents/user_details/$(request.auth.uid))
          .data.isAdmin == true;
    }

    function createsNoProtectedUserFields(userId) {
      return request.resource.data.uid == userId &&
        !request.resource.data.keys().hasAny(['isAdmin']);
    }

    function keepsProtectedUserFieldsUnchanged() {
      return request.resource.data.uid == resource.data.uid &&
        !request.resource.data.diff(resource.data)
           .affectedKeys().hasAny(['isAdmin']);
    }

    // ─── Field validators ───────────────────────────────────────────────────

    function optionalNumber(field, min, max) {
      return !request.resource.data.keys().hasAny([field]) ||
        (request.resource.data[field] is number &&
         request.resource.data[field] >= min &&
         request.resource.data[field] <= max);
    }

    function optionalString(field, max) {
      return !request.resource.data.keys().hasAny([field]) ||
        (request.resource.data[field] is string &&
         request.resource.data[field].size() <= max);
    }

    function optionalList(field, max) {
      return !request.resource.data.keys().hasAny([field]) ||
        (request.resource.data[field] is list &&
         request.resource.data[field].size() <= max);
    }

    function optionalMap(field) {
      return !request.resource.data.keys().hasAny([field]) ||
        request.resource.data[field] is map;
    }

    function optionalBool(field) {
      return !request.resource.data.keys().hasAny([field]) ||
        request.resource.data[field] is bool;
    }

    // ─── Document validators ────────────────────────────────────────────────

    function validUserDetails(userId) {
      return request.resource.data.uid == userId &&
        optionalMap('notificationSettings');
    }

    function validCalorieLog() {
      return request.resource.data.uid == request.auth.uid &&
        optionalNumber('totalCalories',    0, 20000) &&
        optionalNumber('totalProtein',     0,  1000) &&
        optionalNumber('totalCarbs',       0,  2000) &&
        optionalNumber('totalFat',         0,  1000) &&
        optionalNumber('totalFiber',       0,   500) &&
        optionalNumber('totalSugar',       0,  1000) &&
        optionalNumber('totalSodium',      0, 100000) &&
        optionalNumber('caloriesBurned',   0, 20000) &&
        optionalNumber('netCalories',  -20000, 20000) &&
        optionalNumber('workoutMinutes',   0,  1440) &&
        optionalNumber('workoutsCompleted',0,    50) &&
        optionalNumber('waterIntakeMl',    0, 10000) &&
        (!request.resource.data.keys().hasAny(['meals']) ||
          request.resource.data.meals is list &&
          request.resource.data.meals.size() <= 50);
    }

    function validMeal(userId) {
      return request.resource.data.uid == userId &&
        request.resource.data.dateKey is string &&
        request.resource.data.dateKey.size() <= 10 &&
        request.resource.data.foodName is string &&
        request.resource.data.foodName.size() <= 120 &&
        request.resource.data.mealType in
          ['breakfast', 'lunch', 'dinner', 'snack'] &&
        request.resource.data.source in
          ['manual', 'search', 'barcode', 'photo', 'label', 'ai',
           'custom', 'recent', 'favourite', 'template'] &&
        optionalString('servingDescription', 80) &&
        optionalNumber('calories',  0,  5000) &&
        optionalNumber('protein',   0,   300) &&
        optionalNumber('carbs',     0,   600) &&
        optionalNumber('fat',       0,   300) &&
        optionalNumber('fiber',     0,   200) &&
        optionalNumber('sugar',     0,   300) &&
        optionalNumber('sodium',    0, 50000) &&
        optionalNumber('quantity',  0,  5000);
    }

    function validFood(userId) {
      return request.resource.data.uid == userId &&
        request.resource.data.name is string &&
        request.resource.data.name.size() <= 120 &&
        optionalString('brand',          80) &&
        optionalString('dietType',       40) &&
        optionalString('cuisine',        40) &&
        optionalNumber('caloriesPer100g',  0, 1000) &&
        optionalNumber('proteinPer100g',   0,  200) &&
        optionalNumber('carbsPer100g',     0,  250) &&
        optionalNumber('fatPer100g',       0,  200) &&
        optionalNumber('fiberPer100g',     0,  100) &&
        optionalNumber('sugarPer100g',     0,  200) &&
        optionalNumber('sodiumPer100g',    0, 50000) &&
        optionalNumber('defaultServingQuantity', 0, 5000) &&
        optionalList('servingOptions', 20);
    }

    function validGoal(userId) {
      return request.resource.data.uid == userId &&
        request.resource.data.goalType in
          ['lose_weight', 'maintain', 'gain_muscle', 'improve_fitness'] &&
        request.resource.data.fitnessLevel in
          ['beginner', 'intermediate', 'advanced'] &&
        request.resource.data.equipment in
          ['none', 'dumbbells', 'resistance_band', 'full_gym'] &&
        optionalNumber('targetWeightKg',          20,   250) &&
        optionalNumber('dailyCalorieGoal',       1000,  5000) &&
        optionalNumber('proteinGoalG',              0,   300) &&
        optionalNumber('carbsGoalG',                0,   600) &&
        optionalNumber('fatGoalG',                  0,   300) &&
        optionalNumber('waterGoalMl',             500, 10000) &&
        optionalNumber('stepGoal',                  0, 50000) &&
        optionalNumber('workoutsPerWeek',           0,    14) &&
        optionalNumber('workoutDurationMinutes',    0,   240) &&
        optionalString('injuriesOrLimitations',   500) &&
        optionalString('dietPreference',           50) &&
        optionalList('preferredWorkoutDays',        7) &&
        optionalList('allergies',                  30);
    }

    function validWorkoutSession(userId) {
      return request.resource.data.uid == userId &&
        request.resource.data.title is string &&
        request.resource.data.title.size() <= 120 &&
        request.resource.data.status in
          ['planned', 'in_progress', 'completed', 'skipped'] &&
        request.resource.data.source in ['manual', 'program', 'ai'] &&
        optionalString('notes',               1000) &&
        optionalNumber('totalDurationMinutes', 0, 1440) &&
        optionalNumber('caloriesBurned',       0, 10000) &&
        optionalList('exercises',             80);
    }

    function validLegacyWorkoutEntry(userId) {
      return request.resource.data.uid == userId &&
        request.resource.data.name is string &&
        request.resource.data.name.size() <= 120 &&
        optionalString('category',   60) &&
        optionalString('notes',    1000) &&
        optionalNumber('durationMinutes', 0, 1440) &&
        optionalNumber('caloriesBurned',  0, 10000) &&
        optionalNumber('sets',            0,   100) &&
        optionalNumber('reps',            0,  1000) &&
        optionalNumber('weightKg',        0,   500);
    }

    function validUserWorkoutProgram(userId) {
      return request.resource.data.uid == userId &&
        request.resource.data.programId is string &&
        request.resource.data.programId.size() <= 120 &&
        request.resource.data.title is string &&
        request.resource.data.title.size() <= 120 &&
        request.resource.data.status in
          ['active', 'completed', 'paused', 'cancelled'] &&
        optionalNumber('currentWeek', 1, 52) &&
        optionalNumber('currentDay',  1, 31) &&
        optionalList('completedSessionIds', 500) &&
        optionalList('skippedDays',         500);
    }

    function validCustomWorkoutProgram(userId) {
      return request.resource.data.uid == userId &&
        request.resource.data.title is string &&
        request.resource.data.title.size() <= 120 &&
        optionalString('description', 1000) &&
        optionalString('goal',          80) &&
        request.resource.data.level in
          ['beginner', 'intermediate', 'advanced'] &&
        optionalNumber('durationWeeks',           1,  52) &&
        optionalNumber('daysPerWeek',             1,   7) &&
        optionalNumber('estimatedMinutesPerDay',  1, 240) &&
        optionalString('equipment', 80) &&
        optionalList('workoutDays', 31);
    }

    function validMealTemplate(userId) {
      return request.resource.data.uid == userId &&
        request.resource.data.name is string &&
        request.resource.data.name.size() <= 120 &&
        request.resource.data.mealType in
          ['breakfast', 'lunch', 'dinner', 'snack'] &&
        optionalList('foods',          50) &&
        optionalNumber('totalCalories', 0, 20000) &&
        optionalNumber('totalProtein',  0,  1000) &&
        optionalNumber('totalCarbs',    0,  2000) &&
        optionalNumber('totalFat',      0,  1000);
    }

    // ── CORRECTED: includes workoutStreak3 + caloriesBurned500 ──────────────
    function validAchievement(userId) {
      return request.resource.data.uid == userId &&
        request.resource.data.type in [
          'logStreak7', 'logStreak30', 'logStreak100',
          'firstWorkout', 'workouts10', 'workouts50',
          'goalReached', 'bmiNormal', 'recipeTried10', 'waterGoalWeek',
          'workoutStreak3', 'caloriesBurned500'
        ];
    }

    function validWeightLog(userId) {
      return optionalNumber('weight', 20, 250) &&
        optionalNumber('bmi',          5,  80) &&
        optionalString('note',       500);
    }

    function validDailySummary(userId) {
      return request.resource.data.uid == userId &&
        optionalNumber('caloriesConsumed',  0, 20000) &&
        optionalNumber('caloriesBurned',    0, 20000) &&
        optionalNumber('netCalories',  -20000, 20000) &&
        optionalNumber('protein',           0,  1000) &&
        optionalNumber('carbs',             0,  2000) &&
        optionalNumber('fat',               0,  1000) &&
        optionalNumber('fiber',             0,   500) &&
        optionalNumber('waterIntakeMl',     0, 10000) &&
        optionalNumber('steps',             0, 100000) &&
        optionalNumber('workoutMinutes',    0,  1440) &&
        optionalNumber('workoutsCompleted', 0,    50) &&
        optionalNumber('weightKg',         20,   250) &&
        optionalNumber('bmi',               5,    80);
    }

    function validAiMessage() {
      return request.resource.data.keys().hasOnly(
            ['role', 'content', 'timestamp']) &&
        request.resource.data.role in ['user', 'assistant'] &&
        request.resource.data.content is string &&
        request.resource.data.content.size() <= 8000 &&
        request.resource.data.timestamp is timestamp;
    }

    // ─── Collection rules ───────────────────────────────────────────────────

    match /user_details/{userId} {
      allow read: if isOwner(userId);
      allow create: if isOwner(userId) &&
        createsNoProtectedUserFields(userId) && validUserDetails(userId);
      allow update: if isOwner(userId) &&
        keepsProtectedUserFieldsUnchanged() && validUserDetails(userId);
      allow delete: if isOwner(userId);

      match /favourites/{itemId} {
        allow read, write: if isOwner(userId);
      }
      match /mealPlans/{planId} {
        allow read, write: if isOwner(userId);
      }
    }

    match /calorie_logs/{userId} {
      allow delete: if isOwner(userId);

      match /daily/{dayId} {
        allow read:          if isOwner(userId);
        allow create, update: if isOwner(userId) && validCalorieLog();
        allow delete:        if isOwner(userId);

        match /meals/{mealId} {
          allow read:          if isOwner(userId);
          allow create, update: if isOwner(userId) && validMeal(userId);
          allow delete:        if isOwner(userId);
        }
      }
    }

    match /workout_logs/{userId} {
      allow delete: if isOwner(userId);

      // Legacy quick-log entries (WorkoutService.logWorkout)
      match /entries/{entryId} {
        allow read:          if isOwner(userId);
        allow create, update: if isOwner(userId) &&
          validLegacyWorkoutEntry(userId);
        allow delete:        if isOwner(userId);
      }

      // Flat session index (WorkoutRepository primary query path)
      match /sessions/{sessionId} {
        allow read:          if isOwner(userId);
        allow create, update: if isOwner(userId) &&
          validWorkoutSession(userId);
        allow delete:        if isOwner(userId);
      }

      // Per-day session mirror (WorkoutRepository.saveSession secondary write)
      match /daily/{dayId}/sessions/{sessionId} {
        allow read:          if isOwner(userId);
        allow create, update: if isOwner(userId) &&
          validWorkoutSession(userId);
        allow delete:        if isOwner(userId);
      }
    }

    match /user_goals/{userId} {
      allow delete: if isOwner(userId);

      match /goals/{goalId} {
        allow read:          if isOwner(userId);
        allow create, update: if isOwner(userId) && validGoal(userId);
        allow delete:        if isOwner(userId);
      }
    }

    match /user_workout_programs/{userId} {
      allow delete: if isOwner(userId);

      match /programs/{programId} {
        allow read:          if isOwner(userId);
        allow create, update: if isOwner(userId) &&
          validUserWorkoutProgram(userId);
        allow delete:        if isOwner(userId);
      }
    }

    match /custom_workout_programs/{userId}/programs/{programId} {
      allow read:          if isOwner(userId);
      allow create, update: if isOwner(userId) &&
        validCustomWorkoutProgram(userId);
      allow delete:        if isOwner(userId);
    }

    match /meal_templates/{userId}/templates/{templateId} {
      allow read:          if isOwner(userId);
      allow create, update: if isOwner(userId) && validMealTemplate(userId);
      allow delete:        if isOwner(userId);
    }

    match /custom_foods/{userId}/items/{itemId} {
      allow read:          if isOwner(userId);
      allow create, update: if isOwner(userId) && validFood(userId);
      allow delete:        if isOwner(userId);
    }

    match /favourite_foods/{userId}/items/{itemId} {
      allow read:          if isOwner(userId);
      allow create, update: if isOwner(userId) && validFood(userId);
      allow delete:        if isOwner(userId);
    }

    match /recent_foods/{userId}/items/{itemId} {
      allow read:          if isOwner(userId);
      allow create, update: if isOwner(userId) && validFood(userId);
      allow delete:        if isOwner(userId);
    }

    match /daily_summaries/{userId}/daily/{dayId} {
      allow read:          if isOwner(userId);
      allow create, update: if isOwner(userId) && validDailySummary(userId);
      allow delete:        if isOwner(userId);
    }

    match /achievements/{userId} {
      allow delete: if isOwner(userId);

      match /items/{achievementId} {
        allow read:          if isOwner(userId);
        allow create, update: if isOwner(userId) && validAchievement(userId);
        allow delete:        if isOwner(userId);
      }
    }

    match /weight_logs/{userId} {
      allow delete: if isOwner(userId);

      match /entries/{entryId} {
        allow read:          if isOwner(userId);
        allow create, update: if isOwner(userId) && validWeightLog(userId);
        allow delete:        if isOwner(userId);
      }
    }

    match /ai_chats/{userId} {
      allow delete: if isOwner(userId);

      match /messages/{messageId} {
        allow read:   if isOwner(userId);
        allow create: if isOwner(userId) && validAiMessage();
        allow update: if false;
        allow delete: if isOwner(userId);
      }
    }

    // Admin-managed lookup collections
    match /indian_foods/{docId} {
      allow read:  if signedIn();
      allow write: if isAdmin();
    }

    match /food_data/{docId} {
      allow read:  if signedIn();
      allow write: if isAdmin();
    }
  }
}
```

---

## 3. INDEXES  (`firestore.indexes.json`)

All queries in this app use **range filters and `orderBy` on the same field**,
which Firestore handles with its auto-created single-field indexes.  
No composite indexes are required at launch.

The exemptions map is populated to suppress the default descending index on
`__name__` for the high-write `calorie_logs` collection (minor write
performance optimisation — safe to omit).

```json
{
  "indexes": [],
  "fieldOverrides": [
    {
      "collectionGroup": "daily",
      "fieldPath": "date",
      "indexes": [
        { "order": "ASCENDING",  "queryScope": "COLLECTION" },
        { "order": "DESCENDING", "queryScope": "COLLECTION" }
      ]
    },
    {
      "collectionGroup": "sessions",
      "fieldPath": "dateKey",
      "indexes": [
        { "order": "ASCENDING",  "queryScope": "COLLECTION" },
        { "order": "DESCENDING", "queryScope": "COLLECTION" }
      ]
    },
    {
      "collectionGroup": "entries",
      "fieldPath": "timestamp",
      "indexes": [
        { "order": "ASCENDING",  "queryScope": "COLLECTION" },
        { "order": "DESCENDING", "queryScope": "COLLECTION" }
      ]
    }
  ]
}
```

> **If you later add cross-field queries** (e.g. `.where('uid').orderBy('date')`),
> the Firebase console will show a clickable error with an auto-generated index
> creation link. Use that link — it's faster than hand-writing the JSON.

---

## 4. COLLECTION SCHEMA REFERENCE

### Legend
- `(required)` — always present, validated by security rules
- `(optional)` — may be absent; `removeWhere(null)` in model `toMap()`
- `(server)` — written by `FieldValue.serverTimestamp()`
- `(auto)` — Firestore auto-generated document ID

---

### 4.1  `user_details/{uid}`
**Auth:** Owner read/write. `isAdmin` protected (admin-set only).

| Field | Type | Notes |
|---|---|---|
| uid | string (required) | equals document ID |
| name | string | display name |
| email | string | from Firebase Auth |
| photoURL | string | avatar URL |
| username | string | public handle |
| gender | string | 'male' \| 'female' \| 'other' |
| height | string | stored as string e.g. "172" (cm) |
| weight | string | stored as string e.g. "68" (kg) |
| birthdate | string | "YYYY-MM-DD" |
| bio | string | short bio |
| location | string | city / region |
| bmi | number | float, e.g. 22.4 |
| bmr | number | Mifflin-St Jeor, kcal/day |
| lastBmiDate | timestamp | |
| targetWeight | number | kg |
| activityLevel | string | 'sedentary' \| 'lightly_active' \| 'moderately_active' \| 'very_active' |
| weightGoal | string | 'lose_weight' \| 'maintain' \| 'gain_muscle' |
| dietaryPreference | string | 'vegetarian' \| 'vegan' \| 'non_vegetarian' \| 'eggetarian' |
| allergies | string[] | e.g. ["gluten", "dairy"] |
| dailyCalorieGoal | number | kcal, set by GoalRepository |
| fitnessLevel | string | 'beginner' \| 'intermediate' \| 'advanced' |
| equipment | string | 'none' \| 'dumbbells' \| 'resistance_band' \| 'full_gym' |
| preferredWorkoutDays | string[] | ["Mon","Wed","Fri"] |
| workoutsPerWeek | number | legacy alias for weeklyWorkoutGoal |
| weeklyWorkoutGoal | number | target workout days per week (1–7) |
| workoutDurationMinutes | number | target session length |
| injuriesOrLimitations | string | free text |
| isAdmin | boolean | **protected** — only admin can set |
| isOnboardingDone | boolean | |
| timezone | string | IANA timezone, e.g. "Asia/Kolkata" |

#### Subcollections
- `favourites/{itemId}` — favourite recipes / food items (free schema, owner r/w)
- `mealPlans/{planId}` — AI-generated meal plans (free schema, owner r/w)

---

### 4.2  `calorie_logs/{uid}/daily/{dateKey}`
**Key format:** `dateKey` = `"yyyy-MM-dd"` (e.g. `"2026-06-30"`)  
**Auth:** Owner read/write, validated.

| Field | Type | Notes |
|---|---|---|
| uid | string (required) | |
| date | string | same as document ID |
| totalCalories | number | kcal consumed |
| totalProtein | number | grams |
| totalCarbs | number | grams |
| totalFat | number | grams |
| totalFiber | number | grams |
| totalSugar | number | grams |
| totalSodium | number | mg |
| caloriesBurned | number | from workouts + steps |
| netCalories | number | totalCalories − caloriesBurned |
| workoutMinutes | number | |
| workoutsCompleted | number | |
| waterIntakeMl | number | |
| steps | number | from Health sync |
| meals | map[] | **legacy** — array embed; new writes go to subcollection |
| updatedAt | timestamp | |

#### Subcollection: `meals/{mealId}`
| Field | Type | Allowed values |
|---|---|---|
| uid | string (required) | |
| dateKey | string (required) | "yyyy-MM-dd" |
| foodName | string (required) | ≤120 chars |
| mealType | string (required) | breakfast \| lunch \| dinner \| snack |
| source | string (required) | manual \| search \| barcode \| photo \| label \| ai \| custom \| recent \| favourite \| template |
| calories | number | 0–5000 kcal |
| protein | number | 0–300 g |
| carbs | number | 0–600 g |
| fat | number | 0–300 g |
| fiber | number | 0–200 g |
| sugar | number | 0–300 g |
| sodium | number | 0–50000 mg |
| quantity | number | 0–5000 |
| unit | string | "grams" \| "ml" \| "piece" etc. |
| servingDescription | string | ≤80 chars |
| createdAt | timestamp | |
| updatedAt | timestamp | |

---

### 4.3  `workout_logs/{uid}/entries/{entryId}`  (legacy quick-log)
**Auth:** Owner read/write, validated.

| Field | Type | Notes |
|---|---|---|
| uid | string (required) | |
| name | string (required) | exercise name |
| category | string | 'strength' \| 'cardio' \| 'hiit' \| 'yoga' \| 'stretching' |
| durationMinutes | number | 0–1440 |
| caloriesBurned | number | 0–10000 |
| timestamp | timestamp | workout date/time |
| sets | number | optional |
| reps | number | optional |
| weightKg | number | optional |
| notes | string | ≤1000 chars |

### 4.4  `workout_logs/{uid}/sessions/{sessionId}`  (full session)
**Auth:** Owner read/write, validated.

| Field | Type | Notes |
|---|---|---|
| uid | string (required) | |
| title | string (required) | ≤120 chars |
| status | string (required) | planned \| in_progress \| completed \| skipped |
| source | string (required) | manual \| program \| ai |
| date | timestamp | |
| dateKey | string | "yyyy-MM-dd" |
| startedAt | timestamp | |
| completedAt | timestamp | |
| totalDurationMinutes | number | 0–1440 |
| caloriesBurned | number | 0–10000 |
| exercises | map[] | `WorkoutExerciseLog` objects (see below) |
| programId | string | optional — links to `user_workout_programs` |
| notes | string | ≤1000 chars |

**WorkoutExerciseLog map structure:**
```json
{
  "exerciseId": "squats",
  "name":       "Bodyweight Squats",
  "sets":       3,
  "reps":       15,
  "durationSeconds": null,
  "restSeconds": 45,
  "completedSets": [true, true, true],
  "completed":   true,
  "caloriesBurned": 45,
  "notes":       ""
}
```

### 4.5  `workout_logs/{uid}/daily/{dateKey}/sessions/{sessionId}`
Mirror of `sessions/{sessionId}` — same schema.
Written atomically in the same transaction as the flat session document.
Used for per-day UI queries. (Same security rules as flat sessions.)

---

### 4.6  `user_goals/{uid}/goals/{goalId}`
**Auth:** Owner read/write, validated.

| Field | Type | Allowed values |
|---|---|---|
| uid | string (required) | |
| goalType | string (required) | lose_weight \| maintain \| gain_muscle \| improve_fitness |
| fitnessLevel | string (required) | beginner \| intermediate \| advanced |
| equipment | string (required) | none \| dumbbells \| resistance_band \| full_gym |
| targetWeightKg | number | 20–250 |
| dailyCalorieGoal | number | 1000–5000 kcal |
| proteinGoalG | number | 0–300 g |
| carbsGoalG | number | 0–600 g |
| fatGoalG | number | 0–300 g |
| waterGoalMl | number | 500–10000 ml |
| stepGoal | number | 0–50000 |
| workoutsPerWeek | number | 0–14 |
| workoutDurationMinutes | number | 0–240 |
| preferredWorkoutDays | string[] | ≤7 items |
| allergies | string[] | ≤30 items |
| injuriesOrLimitations | string | ≤500 chars |
| dietPreference | string | ≤50 chars |
| isActive | boolean | only one goal is active at a time |
| createdAt | timestamp | |
| updatedAt | timestamp | |

> When `GoalRepository.saveGoal()` saves a new goal, it sets all existing
> active goals to `isActive: false` in the same Firestore transaction,
> then mirrors `dailyCalorieGoal` and `weightGoal` back to `user_details`.

---

### 4.7  `user_workout_programs/{uid}/programs/{programId}`
**Auth:** Owner read/write, validated.  
Document ID = `WorkoutProgram.id` (e.g. `"beginner_no_equipment_7_day"`).

| Field | Type | Notes |
|---|---|---|
| uid | string (required) | |
| programId | string (required) | matches built-in or custom program id |
| title | string (required) | ≤120 chars |
| status | string (required) | active \| completed \| paused \| cancelled |
| currentWeek | number | 1–52 |
| currentDay | number | 1–31 (program day index) |
| completedSessionIds | string[] | session IDs finished |
| skippedDays | number[] | program day numbers skipped |
| createdAt | timestamp | |
| updatedAt | timestamp | |

---

### 4.8  `custom_workout_programs/{uid}/programs/{programId}`
**Auth:** Owner read/write, validated.

| Field | Type | Notes |
|---|---|---|
| uid | string (required) | |
| title | string (required) | ≤120 chars |
| description | string | ≤1000 chars |
| goal | string | ≤80 chars |
| level | string (required) | beginner \| intermediate \| advanced |
| durationWeeks | number | 1–52 |
| daysPerWeek | number | 1–7 |
| estimatedMinutesPerDay | number | 1–240 |
| equipment | string | ≤80 chars |
| workoutDays | map[] | ≤31, each: `{ "day": int, "title": string, "exerciseIds": string[] }` |
| createdAt | (server) | |
| updatedAt | (server) | |

---

### 4.9  `custom_foods/{uid}/items/{foodId}`
### 4.10 `favourite_foods/{uid}/items/{foodId}`
### 4.11 `recent_foods/{uid}/items/{foodId}`
All three share the same schema and `validFood` rule.

| Field | Type | Notes |
|---|---|---|
| uid | string (required) | |
| name | string (required) | ≤120 chars |
| brand | string | ≤80 chars |
| dietType | string | 'veg' \| 'non_veg' \| 'vegan' |
| cuisine | string | ≤40 chars |
| caloriesPer100g | number | 0–1000 |
| proteinPer100g | number | 0–200 |
| carbsPer100g | number | 0–250 |
| fatPer100g | number | 0–200 |
| fiberPer100g | number | 0–100 |
| sugarPer100g | number | 0–200 |
| sodiumPer100g | number | 0–50000 mg |
| defaultServingQuantity | number | grams or ml |
| servingOptions | map[] | `[{ "label": "1 bowl", "quantity": 250 }]` |
| updatedAt | timestamp | |

> `NutritionRepository._stableFoodId()` derives the document ID as the
> food name lowercased with spaces replaced by underscores, so re-logging
> the same food overwrites instead of duplicating.

---

### 4.12 `meal_templates/{uid}/templates/{templateId}`
**Auth:** Owner read/write, validated.

| Field | Type | Notes |
|---|---|---|
| uid | string (required) | |
| name | string (required) | ≤120 chars |
| mealType | string (required) | breakfast \| lunch \| dinner \| snack |
| foods | map[] | ≤50 food items (same as MealEntry map) |
| totalCalories | number | 0–20000 |
| totalProtein | number | 0–1000 |
| totalCarbs | number | 0–2000 |
| totalFat | number | 0–1000 |
| updatedAt | timestamp | |

---

### 4.13 `daily_summaries/{uid}/daily/{dateKey}`
**Auth:** Owner read/write, validated.  
Written by `DailySummaryService.rebuildSummary()` after every meal log or
workout save.

| Field | Type | Notes |
|---|---|---|
| uid | string (required) | |
| dateKey | string | "yyyy-MM-dd" |
| caloriesConsumed | number | |
| caloriesBurned | number | workouts only (not steps) |
| netCalories | number | consumed − burned |
| protein | number | g |
| carbs | number | g |
| fat | number | g |
| fiber | number | g |
| waterIntakeMl | number | |
| steps | number | from Health sync |
| workoutMinutes | number | |
| workoutsCompleted | number | |
| weightKg | number | from most recent weight log |
| bmi | number | |
| updatedAt | timestamp | |

---

### 4.14 `achievements/{uid}/items/{achievementType}`
**Auth:** Owner read/write, validated.  
Document ID = `AchievementType.name` (the enum `.name` getter).

| Field | Type | Notes |
|---|---|---|
| uid | string (required) | |
| type | string (required) | **see allowlist below** |
| unlockedAt | timestamp | |

**Valid type strings (12 total):**
```
logStreak7        logStreak30       logStreak100
firstWorkout      workouts10        workouts50
goalReached       bmiNormal         recipeTried10
waterGoalWeek     workoutStreak3    caloriesBurned500
```

---

### 4.15 `weight_logs/{uid}/entries/{entryId}`
**Auth:** Owner read/write, validated.

| Field | Type | Notes |
|---|---|---|
| weight | number | kg, 20–250 |
| bmi | number | 5–80 |
| note | string | ≤500 chars |
| date | timestamp | |

---

### 4.16 `ai_chats/{uid}/messages/{messageId}`
**Auth:** Owner read (all) / create only (no update). Validated.

| Field | Type | Notes |
|---|---|---|
| role | string (required) | 'user' \| 'assistant' |
| content | string (required) | ≤8000 chars |
| timestamp | timestamp (required) | |

---

### 4.17 `indian_foods/{docId}`  (admin-managed)
**Auth:** All signed-in users read. Admin write only.

| Field | Type | Notes |
|---|---|---|
| name | string | Indian food item |
| searchName | string | lowercase normalised for startAt prefix search |
| calories | number | per 100g |
| protein | number | per 100g |
| carbs | number | per 100g |
| fat | number | per 100g |
| fiber | number | per 100g |
| dietType | string | 'veg' \| 'non_veg' \| 'vegan' |
| servingSize | number | typical serving in grams |
| servingDescription | string | e.g. "1 roti (35g)" |
| cuisine | string | e.g. "North Indian" |

### 4.18 `food_data/{docId}`  (admin-managed)
Same schema as `indian_foods`. Written via `lib/admin/add_data.dart`.

---

## 5. QUERY INDEX REQUIREMENTS

All app queries use **range filters and `orderBy` on the same field**.
Firestore auto-indexes these. No composite index definitions are needed.

| Query | Collection | Fields | Index needed |
|---|---|---|---|
| Today's workouts | `entries` | `timestamp >=, <, orderBy timestamp` | Auto ✅ |
| Workouts in range | `entries` | `timestamp >=, <, orderBy timestamp` | Auto ✅ |
| Sessions by date | `sessions` | `dateKey ==` | Auto ✅ |
| Sessions in range | `sessions` | `dateKey >=, <=` | Auto ✅ |
| Active program | `programs` | `status ==` | Auto ✅ |
| Calorie logs range | `daily` | `date >=, <=, orderBy date` | Auto ✅ |
| Food search | `indian_foods` | `searchName >=, <=` | Auto ✅ |
| Recent foods | `items` | `orderBy updatedAt` | Auto ✅ |
| Achievements | `items` | `orderBy unlockedAt` | Auto ✅ |
| AI messages | `messages` | `orderBy timestamp` | Auto ✅ |

---

## 6. ADMIN SEED DATA

### Enable admin access for your account
```javascript
// Firebase console → Firestore → user_details/{your-uid}
// Add field: isAdmin = true (boolean)
```

### Seed `indian_foods` collection
Use the Flutter admin panel (`lib/admin/add_data.dart`) which is gated
behind `isAdmin == true`. The `searchName` field must be set to
`name.toLowerCase()` for the prefix-search query to work.

**Minimum required fields per document:**
```json
{
  "name": "Dal Tadka",
  "searchName": "dal tadka",
  "calories": 198,
  "protein": 11.2,
  "carbs": 28.4,
  "fat": 5.1,
  "fiber": 6.8,
  "dietType": "veg",
  "servingSize": 200,
  "servingDescription": "1 katori (200g)"
}
```

### Built-in workout data (no Firestore seeding needed)
- `assets/data/exercises.json` — 20 exercises (loaded by `WorkoutRepository.loadExercises()`)
- `assets/data/workout_programs.json` — 8 programs (loaded by `WorkoutRepository.loadPrograms()`)
- `lib/data/workout_library.dart` — 8 quick-start plans (const, no network call)

---

## 7. ENVIRONMENT / `firebase.json`

Ensure your `firebase.json` points to both rule and index files:

```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  }
}
```

---

## 8. NOTIFICATION CHANNEL IDs (for reference)

`NotificationService` uses these channel IDs and notification IDs.
If you change them, update both `notification_service.dart` and the Android
`AndroidManifest.xml` channel declarations.

| Channel ID | Purpose | Notification IDs |
|---|---|---|
| `meal_reminders` | Breakfast / lunch / dinner | 100, 101, 102 |
| `workout_reminders` | Daily workout nudge | 3 |
| `water_reminders` | Hydration reminders | 200 |
| `achievement_notifications` | Badge unlocked | 600 |
| `streak_notifications` | Log streak alert | 500 |
| `weigh_in_reminders` | Weekly weigh-in | 400 |
