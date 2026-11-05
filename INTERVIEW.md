# Interview case study

Verified upgrade: 2026-11-05. Scope: job-switch and interview readiness.

Applied AI: validating generated plans inside a usable Flutter product.

## Architecture and engineering decision

A Flutter app combines meal/workout tracking with Firebase-backed accounts and optional AI features through a server-side proxy. Model responses become typed meal and workout objects.

Meal-plan parsing rejects malformed/empty day collections instead of silently dropping entries. Days require positive integer identities and complete meal objects. Supplied nutrient values must be finite and nonnegative; workout duration/day checks reject invalid values.

## Five-minute walkthrough

Start with a valid workout plan, then change its duration or day number to an invalid value. Show malformed meal days and negative nutrients fail validation. Explain why schema checks are only one layer of generated-plan quality.

After the repository's documented dependency setup, run these commands from its root. Use an activated Python environment where applicable; Maven offline mode requires cached dependencies.

```text
flutter test --no-pub
dart analyze lib/models/meal_plan.dart lib/services/ai_service.dart test/ai_response_validation_test.dart
```

## Recorded evidence

33 Flutter tests passed. Targeted Dart analysis reported no issues. These tests use original structured fixtures without live AI calls.

Behavioral regressions were reproduced before their fixes. Passing contract tests demonstrate the named behavior; they are not an AI accuracy rating.

## Defensible resume wording

> Added typed validation for generated meal and workout plans, preventing malformed collections and invalid numeric values from becoming accepted plans.

Use this wording only after you can reproduce and explain the implementation. Add measured numbers with their dataset and environment; never substitute synthetic results for real-user impact.

## Questions to prepare

Which values are missing versus explicitly zero? How should users see an invalid provider response? How would expert review and labeled food portions change evaluation?

## Remaining evidence

No nutritional accuracy, health outcome or expert plan-quality validation was performed. Optional missing nutrients retain the existing zero default. Mobile/Firebase/provider end-to-end and release builds were not reverified in this slice.
