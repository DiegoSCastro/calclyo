import 'package:calclyo/src/features/rule_of_three/domain/rule_of_three_input.dart';
import 'package:fpdart/fpdart.dart';

class RuleOfThreeRepositoryFailure implements Exception {
  const RuleOfThreeRepositoryFailure(this.message);
  final String message;
  @override
  String toString() => 'RuleOfThreeRepositoryFailure: $message';
}

class RuleOfThreeRepository {
  const RuleOfThreeRepository();

  TaskEither<RuleOfThreeRepositoryFailure, RuleOfThreeResult> solve(
    RuleOfThreeInput input,
  ) {
    return TaskEither.tryCatch(
      () async {
        if (input.a == 0) {
          throw const RuleOfThreeRepositoryFailure('Value "a" must be non-zero');
        }
        final x = _compute(input);
        final steps = _stepsFor(input, x);
        return RuleOfThreeResult(x: x, steps: steps);
      },
      (error, _) => RuleOfThreeRepositoryFailure(error.toString()),
    );
  }

  double _compute(RuleOfThreeInput input) {
    return switch (input.kind) {
      RuleOfThreeKind.direct => (input.b * input.c) / input.a,
      RuleOfThreeKind.inverse => (input.a * input.b) / input.c,
    };
  }

  List<String> _stepsFor(RuleOfThreeInput input, double x) {
    final kindLabel = input.kind == RuleOfThreeKind.direct
        ? 'Direct'
        : 'Inverse';
    return [
      'Proportion: $kindLabel rule of three',
      'Given: a=${input.a}, b=${input.b}, c=${input.c}',
      if (input.kind == RuleOfThreeKind.direct)
        'Formula: x = (b × c) / a'
      else
        'Formula: x = (a × b) / c',
      'Computation: x = ${x.toStringAsFixed(6)}',
    ];
  }
}
