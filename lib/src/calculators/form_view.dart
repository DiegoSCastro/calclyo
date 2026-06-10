import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/features/history/history_entry.dart';
import 'package:calclyo/src/features/history/history_repository.dart';
import 'package:calclyo/src/features/history/history_view.dart';
import 'package:flutter/material.dart';

/// Generic, schema-driven calculator view.
///
/// Reads a [CalculatorDefinition], builds a form from
/// [CalculatorDefinition.inputSchema] (text fields + controls), runs
/// [CalculatorDefinition.compute] on submit, and renders the result with
/// [CalculatorDefinition.stepRenderer].
///
/// The router hands every calculator page this widget — calculators only
/// need their own `stepRenderer` if they want specialised result layout
/// (the default renders [CalculatorResult] generically).
class CalculatorFormView extends StatefulWidget {
  const CalculatorFormView({
    required this.definition,
    this.initialValues = const <String, String>{},
    super.key,
  });

  final CalculatorDefinition definition;

  /// Pre-filled values for any of the schema's fields/controls. Keys
  /// must match [CalculatorInputField.key] / [CalculatorControl.key];
  /// unknown keys are ignored. When the user opens the form directly
  /// (no history re-run) this is empty and the form uses the schema's
  /// `defaultValue` for every field.
  final Map<String, String> initialValues;

  @override
  State<CalculatorFormView> createState() => _CalculatorFormViewState();
}

class _CalculatorFormViewState extends State<CalculatorFormView> {
  late final Map<String, TextEditingController> _controllers;
  final Map<String, String> _controlValues = {};
  CalculatorResult? _result;
  String? _error;
  HistoryEntry? _lastRecorded;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final field in widget.definition.inputSchema.fields)
        field.key: TextEditingController(
          text: _initialFor(field.key, field.defaultValue),
        ),
    };
    for (final c in widget.definition.inputSchema.controls) {
      if (c is SegmentedToggleControl) {
        final fromInitial = widget.initialValues[c.key];
        if (fromInitial != null && c.options.contains(fromInitial)) {
          _controlValues[c.key] = fromInitial;
        } else {
          _controlValues[c.key] = c.options[c.initialIndex];
        }
      }
    }
  }

  /// Resolve the initial value for a field: explicit prefill wins,
  /// otherwise the schema's `defaultValue`. Returns empty string when
  /// neither is present (preserves the original behaviour).
  String _initialFor(String key, String? fallback) {
    final prefilled = widget.initialValues[key];
    if (prefilled != null) return prefilled;
    return fallback ?? '';
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _onCalculate() async {
    final values = <String, String>{..._controlValues};
    for (final entry in _controllers.entries) {
      values[entry.key] = entry.value.text;
    }
    final result = await widget.definition.compute(values).run();
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _result = null;
        _error = failure.message;
      }),
      (value) {
        final summary = '${value.primaryLabel} = '
            '${value.primary.toStringAsFixed(6)}';
        setState(() {
          _result = value;
          _error = null;
        });
        _recordHistory(values: values, result: summary);
      },
    );
  }

  /// Push the run into history. Best-effort — never throws. De-dupes
  /// consecutive identical runs so spamming Calculate doesn't fill the
  /// list with the same entry over and over.
  void _recordHistory({
    required Map<String, String> values,
    required String result,
  }) {
    if (!HistoryRepositoryProvider.isReady) return;
    final idGen = HistoryIdGenerator();
    final entry = HistoryEntry(
      id: idGen.next(),
      calculatorId: widget.definition.id,
      inputs: Map<String, String>.unmodifiable(values),
      result: result,
      timestamp: DateTime.now().toUtc(),
    );
    final last = _lastRecorded;
    if (last != null &&
        last.calculatorId == entry.calculatorId &&
        _mapsEqual(last.inputs, entry.inputs)) {
      // Same calculator + same inputs as the last submit — treat as a
      // re-run, don't pollute the list.
      _lastRecorded = entry;
      return;
    }
    _lastRecorded = entry;
    // Fire-and-forget: persist directly. The history page will pick
    // it up on its next refresh.
    HistoryRepositoryProvider.instance.add(entry).run();
  }

  bool _mapsEqual(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final definition = widget.definition;
    return Scaffold(
      appBar: AppBar(title: Text(definition.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final control in definition.inputSchema.controls) ...[
              control.build(
                context,
                (v) => setState(() => _controlValues[control.key] = v),
              ),
              const SizedBox(height: 12),
            ],
            for (final field in definition.inputSchema.fields) ...[
              TextField(
                controller: _controllers[field.key],
                keyboardType: _keyboardTypeFor(field),
                decoration: InputDecoration(
                  labelText: field.label,
                  helperText: field.helper,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
            ],
            FilledButton.icon(
              onPressed: _onCalculate,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _ResultArea(
                result: _result,
                error: _error,
                definition: definition,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextInputType _keyboardTypeFor(CalculatorInputField field) {
    switch (field.keyboardType) {
      case CalculatorKeyboardType.text:
        return TextInputType.text;
      case CalculatorKeyboardType.number:
        return TextInputType.numberWithOptions(
          decimal: field.allowDecimal,
          signed: field.allowSigned,
        );
    }
  }
}

class _ResultArea extends StatelessWidget {
  const _ResultArea({
    required this.result,
    required this.error,
    required this.definition,
  });

  final CalculatorResult? result;
  final String? error;
  final CalculatorDefinition definition;

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(child: Text('Error: $error'));
    }
    final r = result;
    if (r == null) {
      return const Center(
        child: Text('Enter values and tap "Calculate"'),
      );
    }
    return SingleChildScrollView(
      child: definition.stepRenderer(context, r),
    );
  }
}
