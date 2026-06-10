# Calclyo

> All-in-one multi-category calculator app with AI step-by-step explanations.

Calclyo brings 100+ calculators into one beautiful, fast app, across categories
like Math, Geometry, Finance, Health, Unit Converter, Everyday, and Science.

## Status

**v0.1.0 — local-first foundation**

This commit boots the app with:

- A category-driven home screen (Math, Geometry, Finance, Health, Converter,
  Everyday, Science)
- A working **Rule of Three** calculator (direct & inverse) with on-screen
  step-by-step explanation
- Clean architecture: `data` / `domain` / `presentation` per feature
- Cubit as state controller, `fpdart` for `TaskEither` error handling (no
  `try/catch` in the app)
- `go_router` for navigation
- Lints: `very_good_analysis`
- `flutter test` ✅, `flutter build apk --debug` ✅

## Run

```bash
flutter pub get
flutter test
flutter run
```

## Architecture

```
lib/
  app/                    # app entry, providers, theming wiring
  src/
    features/
      category/           # category-driven home (data/domain/presentation)
      rule_of_three/      # rule of three calc, full fpdart pipeline
    router/               # go_router config
    theme/                # Material 3 light/dark themes
test/
  rule_of_three_repository_test.dart
  category_repository_test.dart
  widget_test.dart
```

## Roadmap

- More calculators per category (geometry, finance, unit converter, health,
  science, everyday)
- AI step-by-step explanation endpoint (free tier with offline templates;
  Pro tier with LLM-generated explanations)
- Monetization: ads-free tier with optional Pro subscription
- iOS release
- ASO launch (US-first, English)
