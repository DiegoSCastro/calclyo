import 'package:calclyo/src/core/categories.dart';
import 'package:calclyo/src/router/app_router.dart' show AppRouter;
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

/// Description of a single calculator input field.
class CalculatorInputField extends Equatable {
  /// Creates [CalculatorInputField].
  const CalculatorInputField({
    required this.key,
    required this.label,
    this.helper,
    this.defaultValue,
    this.allowDecimal = true,
    this.allowSigned = true,
    this.keyboardType = CalculatorKeyboardType.number,
  });

  /// Stable identifier — used to read the value out of the form map.
  final String key;

  /// Human label shown above the field.
  final String label;

  /// Optional helper text shown beneath the field.
  final String? helper;

  /// Pre-filled value for the field. Shown when the user opens the form and
  /// submitted as-is if the user does not edit it.
  final String? defaultValue;

  /// allowDecimal.
  final bool allowDecimal;

  /// allowSigned.
  final bool allowSigned;

  /// keyboardType.
  final CalculatorKeyboardType keyboardType;

  @override
  List<Object?> get props => [
    key,
    label,
    helper,
    defaultValue,
    allowDecimal,
    allowSigned,
    keyboardType,
  ];
}

/// How the form view renders the on-screen keyboard for an input field.
enum CalculatorKeyboardType {
  /// Standard decimal/signed numeric keyboard.
  number,

  /// Plain text keyboard. Use for dates, time strings, roman numerals, etc.
  text,
}

/// Calculator-specific UI controls that aren't number fields. Each control
/// writes a string value into the values map (so the
/// [CalculatorDefinition.compute] function can still consume a uniform
/// `Map<String, String>`).
sealed class CalculatorControl extends Equatable {
  const CalculatorControl({required this.key});

  /// key.
  final String key;

  /// Build the widget the form view will place in the layout.
  Widget build(BuildContext context, ValueChanged<String> onChanged);
}

/// A single-select toggle rendered as a [SegmentedButton]. Used for things
/// like direct/inverse mode switches — the selected option's label is
/// written to the values map as a string.
class SegmentedToggleControl extends CalculatorControl {
  /// Creates [SegmentedToggleControl].
  const SegmentedToggleControl({
    required super.key,
    required this.options,
    this.initialIndex = 0,
  });

  /// options.
  final List<String> options;

  /// initialIndex.
  final int initialIndex;

  @override
  List<Object?> get props => [key, options, initialIndex];

  @override
  Widget build(BuildContext context, ValueChanged<String> onChanged) {
    return SegmentedButton<int>(
      segments: [
        for (var i = 0; i < options.length; i++)
          ButtonSegment<int>(value: i, label: Text(options[i])),
      ],
      selected: {initialIndex},
      onSelectionChanged: (set) => onChanged(options[set.first]),
    );
  }
}

/// Schema describing what a calculator needs from the user.
///
/// Each calculator exposes a fixed [fields] list (text/number inputs) and
/// optional [controls] list (segmented buttons, sliders, etc.). The UI
/// layer builds a form from this schema; the compute function receives a
/// `Map<String, String>` keyed by [CalculatorInputField.key] /
/// [CalculatorControl.key].
class CalculatorInputSchema extends Equatable {
  /// Creates [CalculatorInputSchema].
  const CalculatorInputSchema({
    this.fields = const [],
    this.controls = const [],
  });

  /// fields.
  final List<CalculatorInputField> fields;

  /// controls.
  final List<CalculatorControl> controls;

  @override
  List<Object?> get props => [fields, controls];
}

/// Result of a calculator computation.
///
/// [primary] is the headline answer (rendered large), [steps] is the
/// human-readable explanation, and [primaryLabel] is shown next to the
/// value (e.g. "x =", "Area =").
class CalculatorResult extends Equatable {
  /// Creates [CalculatorResult].
  const CalculatorResult({
    required this.primary,
    required this.steps,
    this.primaryLabel = 'Result',
  });

  /// primary.
  final double primary;

  /// primaryLabel.
  final String primaryLabel;

  /// steps.
  final List<String> steps;

  @override
  List<Object?> get props => [primary, primaryLabel, steps];
}

/// Failure emitted by a calculator's compute function. Messages should be
/// user-facing — the UI renders them verbatim.
class CalculatorFailure implements Exception {
  /// Creates [CalculatorFailure].
  const CalculatorFailure(this.message);

  /// message.
  final String message;

  @override
  String toString() => 'CalculatorFailure: $message';
}

/// Shared contract every calculator implementation must satisfy.
///
/// Each calculator is a single const instance exported from its own file
/// under `lib/src/calculators/<id>/<id>.dart`. The [CategoryRegistry]
/// collects them and the router/render layer reads everything (id, name,
/// icon, accent, route, inputs, compute) from this object — no other code
/// path needs to know about a specific calculator.
class CalculatorDefinition extends Equatable {
  /// CalculatorDefinition.
  const CalculatorDefinition({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.route,
    required this.category,
    required this.inputSchema,
    required this.compute,
    required this.stepRenderer,
  });

  /// Unique id, e.g. `rule-of-three`. Used for routing and registry lookup.
  final String id;

  /// Display name shown in lists and app bars.
  final String name;

  /// Short one-liner shown under [name] in category lists.
  final String subtitle;

  /// Material icon for the calculator tile.
  final IconData icon;

  /// Accent color used to highlight the result.
  final Color accent;

  /// Route path the [AppRouter] registers.
  final String route;

  /// Which category this calculator belongs to.
  final CalculatorCategoryId category;

  /// Form schema the UI builds inputs from.
  final CalculatorInputSchema inputSchema;

  /// Pure async function turning raw form input strings into either a
  /// failure or a result. Receiving a [Map] of raw strings (rather than
  /// parsed doubles) lets the same shape serve both numeric and text
  /// inputs (dates, roman numerals, time strings). Returning a
  /// [TaskEither] keeps error handling uniform — no `try/catch` leaks
  /// into the UI layer.
  final TaskEither<CalculatorFailure, CalculatorResult> Function(
    Map<String, String> values,
  )
  compute;

  /// Widget that renders the explanation. Receives the result and the theme.
  final Widget Function(BuildContext context, CalculatorResult result)
  stepRenderer;

  @override
  List<Object?> get props => [
    id,
    name,
    subtitle,
    icon.codePoint,
    accent,
    route,
    category,
    inputSchema,
  ];
}
