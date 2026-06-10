import 'package:equatable/equatable.dart';

/// One persisted record of a successful calculator run.
///
/// The [inputs] map is keyed by [CalculatorInputField.key] /
/// [CalculatorControl.key] and is intentionally `Map<String, String>` so
/// re-runs reproduce exactly what the user submitted (numeric, date, text
/// inputs all share the same shape).
class HistoryEntry extends Equatable {
  const HistoryEntry({
    required this.id,
    required this.calculatorId,
    required this.inputs,
    required this.result,
    required this.timestamp,
  });

  /// Local uuid-ish id. Used as the `ListView` key and to de-dup within
  /// the in-memory list — not exposed to the user.
  final String id;

  /// `CalculatorDefinition.id` this entry belongs to. Used to resolve the
  /// route + display name when re-running.
  final String calculatorId;

  /// Raw form values that produced [result]. Keys mirror the calculator's
  /// `inputSchema`.
  final Map<String, String> inputs;

  /// Human-readable result string. Captured at the moment of the compute
  /// (e.g. `"x = 35.000000"`).
  final String result;

  /// When the calculation ran, in ISO 8601 UTC.
  final DateTime timestamp;

  HistoryEntry copyWith({
    String? id,
    String? calculatorId,
    Map<String, String>? inputs,
    String? result,
    DateTime? timestamp,
  }) {
    return HistoryEntry(
      id: id ?? this.id,
      calculatorId: calculatorId ?? this.calculatorId,
      inputs: inputs ?? this.inputs,
      result: result ?? this.result,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'calculatorId': calculatorId,
        'inputs': inputs,
        'result': result,
        'timestamp': timestamp.toUtc().toIso8601String(),
      };

  /// Decode a single entry. Returns `null` for malformed rows so the
  /// repository can drop them silently rather than crash the whole list.
  static HistoryEntry? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final calculatorId = raw['calculatorId'];
    final inputs = raw['inputs'];
    final result = raw['result'];
    final timestamp = raw['timestamp'];
    if (id is! String || id.isEmpty) return null;
    if (calculatorId is! String || calculatorId.isEmpty) return null;
    if (inputs is! Map) return null;
    if (result is! String) return null;
    if (timestamp is! String) return null;
    final parsedTs = DateTime.tryParse(timestamp);
    if (parsedTs == null) return null;
    final cleanInputs = <String, String>{};
    for (final entry in inputs.entries) {
      final k = entry.key;
      final v = entry.value;
      if (k is String && v is String) {
        cleanInputs[k] = v;
      }
    }
    return HistoryEntry(
      id: id,
      calculatorId: calculatorId,
      inputs: Map<String, String>.unmodifiable(cleanInputs),
      result: result,
      timestamp: parsedTs,
    );
  }

  @override
  List<Object?> get props => [id, calculatorId, inputs, result, timestamp];
}
