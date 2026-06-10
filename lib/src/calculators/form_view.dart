import 'package:calclyo/src/core/calculator.dart';
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
  const CalculatorFormView({required this.definition, super.key});

  final CalculatorDefinition definition;

  @override
  State<CalculatorFormView> createState() => _CalculatorFormViewState();
}

class _CalculatorFormViewState extends State<CalculatorFormView> {
  late final Map<String, TextEditingController> _controllers;
  final Map<String, String> _controlValues = {};
  CalculatorResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final field in widget.definition.inputSchema.fields)
        field.key: TextEditingController(text: field.defaultValue ?? ''),
    };
    for (final c in widget.definition.inputSchema.controls) {
      if (c is SegmentedToggleControl) {
        _controlValues[c.key] = c.options[c.initialIndex];
      }
    }
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
      (value) => setState(() {
        _result = value;
        _error = null;
      }),
    );
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
