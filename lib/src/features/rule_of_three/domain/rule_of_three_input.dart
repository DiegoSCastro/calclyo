import 'package:equatable/equatable.dart';

enum RuleOfThreeKind { direct, inverse }

class RuleOfThreeInput extends Equatable {
  const RuleOfThreeInput({
    required this.a,
    required this.b,
    required this.c,
    required this.kind,
  });

  final double a;
  final double b;
  final double c;
  final RuleOfThreeKind kind;

  @override
  List<Object?> get props => [a, b, c, kind];
}

class RuleOfThreeResult extends Equatable {
  const RuleOfThreeResult({required this.x, required this.steps});

  final double x;
  final List<String> steps;

  @override
  List<Object?> get props => [x, steps];
}
