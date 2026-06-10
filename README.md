# Calclyo

> All-in-one multi-category calculator app with AI step-by-step explanations.

Calclyo brings 100+ calculators into one beautiful, fast app, across categories
like Math, Geometry, Finance, Health, Unit Converter, Everyday, and Science.

## Status

**v0.2.0 — shared calculator contract**

Adds a `CalculatorDefinition` contract so adding a new calculator = one
new file. Every calculator now declares its id, name, subtitle, icon,
accent, route, category, input schema, compute, and step renderer in a
single const instance. The router, home screen, and registry all read
from this object — no per-calculator wiring, no cubit, no async load.

- Rule of Three refactored to the new contract (proof of the model)
- Generic `CalculatorFormView` builds the form from the schema
- `SegmentedToggleControl` covers the direct/inverse kind switch
- `CategoryRegistry` aggregates calculators by category
- 17 tests pass (`flutter test`), `flutter build apk --debug` ✅

Building on v0.1.0:

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
  app/                    # app entry, theming wiring
  src/
    calculator_registry.dart   # single list of every CalculatorDefinition
    core/
      calculator.dart     # CalculatorDefinition contract + input/output types
      categories.dart     # CalculatorCategoryId + CategoryRegistry
    calculators/
      category_list_view.dart   # home screen
      form_view.dart      # generic, schema-driven calculator page
      rule_of_three/
        rule_of_three.dart  # 1 calculator = 1 file (proof of model)
    router/               # go_router config (iterates the registry)
    theme/                # Material 3 light/dark themes
test/
  rule_of_three_test.dart
  calculator_registry_test.dart
  widget_test.dart
```

## Adding a new calculator

1. Create `lib/src/calculators/<id>/<id>.dart`
2. Export a const `CalculatorDefinition` with id, name, subtitle, icon,
   accent, route, category, input schema, compute, and step renderer
3. Append it to `lib/src/calculator_registry.dart`

No router changes, no cubit, no repository. The home screen picks it up
on the next build.

## Roadmap

- More calculators per category (geometry, finance, unit converter, health,
  science, everyday)
- AI step-by-step explanation endpoint (free tier with offline templates;
  Pro tier with LLM-generated explanations)
- Monetization: ads-free tier with optional Pro subscription
- iOS release
- ASO launch (US-first, English)
