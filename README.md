# Calclyo

> All-in-one multi-category calculator app with step-by-step explanations.

Calclyo ships 45+ calculators across 8 categories in one fast, schema-driven
Flutter app. Adding a new calculator = one new file. The router, home screen,
and registry all read from a single `CalculatorDefinition` contract.

## Status

**v0.2.0 — shared calculator contract + 45+ calculators**

- 45+ `CalculatorDefinition`s, one file per calculator
- 8 categories: **Algebra**, **Geometry**, **Converter**, **Lifestyle**,
  **Finance**, **Health**, **Date & Time**, **Science**
- Generic `CalculatorFormView` builds the form from each calculator's schema
- `SegmentedToggleControl` covers mode switches (direct/inverse, dec/hex, etc.)
- `CalculatorRegistry` aggregates calculators by category, exposes
  `findById`, `findByRoute`, and grouped views
- Health calculators show a "For reference only. Not medical advice." banner
- `flutter test` ✅, `flutter analyze` (0 errors, 0 warnings) ✅,
  `flutter build apk --debug` ✅

Building on v0.1.0:
- A category-driven home screen
- A working **Rule of Three** calculator (direct & inverse) with on-screen
  step-by-step explanation
- Clean architecture: `data` / `domain` / `presentation` per feature
- Cubit as state controller, `fpdart` for `TaskEither` error handling
- `go_router` for navigation (every calculator route generated from the
  registry)
- Lints: `very_good_analysis`

## Catalog (v0.2)

| Category | Calculators |
| --- | --- |
| **Algebra** | Rule of Three, Proportion, Ratio, Equations (linear/quadratic/2×2), GCF/LCM, Combinations, Prime Check, Number Generator, Average, Percentage |
| **Geometry** | Triangle, Circle, Rectangle, Polygon (regular), 3D Bodies (cube/sphere/cone/cylinder) |
| **Converter** | Length, Area, Cooking Volume, Temperature, Angle, Weight, Acceleration, Data Storage, Data Transfer, Energy, Force, Fuel, Speed, Power, Numeric Base |
| **Lifestyle** | Roman Numerals, Shoe Size, Clothing Size |
| **Finance** | Unit Price, Sales Tax, Tip, Discount, Loan Payment |
| **Health** | BMI, Body Fat, Caloric Burn *(all show a non-medical-advice banner)* |
| **Date & Time** | Age, Date Add/Subtract, Time Interval |
| **Science** | Ohm's Law, Mileage |

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
      _widgets.dart           # shared step renderer + health-disclaimer banner
      form_view.dart          # generic, schema-driven calculator page
      <id>/<id>.dart          # one file per calculator (45+ files)
    router/               # go_router config (iterates the registry)
    shell/                # AppShell (nav rail + drawer with search/settings/achievements)
    theme/                # Material 3 light/dark themes
test/
  <id>_test.dart          # at least 2 compute tests + 1 id/route assertion per calc
  calculator_registry_test.dart
  widget_test.dart
```

## Adding a new calculator

1. Create `lib/src/calculators/<id>/<id>.dart`
2. Export a const `CalculatorDefinition` with id, name, subtitle, icon,
   accent, route, category, input schema, compute, and step renderer
3. Append it to `lib/src/calculator_registry.dart`
4. Add at least 2 tests in `test/<id>_test.dart`

No router changes, no cubit, no repository. The home screen picks it up
on the next build.

## Roadmap

- AI step-by-step explanation endpoint (free tier with offline templates;
  Pro tier with LLM-generated explanations)
- Monetization: ads + optional Pro subscription
- iOS release
- ASO launch (US-first, English)
