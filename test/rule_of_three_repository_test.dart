import 'package:flutter_test/flutter_test.dart';

import 'package:calclyo/src/features/rule_of_three/data/rule_of_three_repository.dart';
import 'package:calclyo/src/features/rule_of_three/domain/rule_of_three_input.dart';

void main() {
  group('RuleOfThreeRepository', () {
    final repo = RuleOfThreeRepository();

    test('solves direct rule of three', () async {
      final result = await repo
          .solve(
            const RuleOfThreeInput(
              a: 2,
              b: 10,
              c: 7,
              kind: RuleOfThreeKind.direct,
            ),
          )
          .run();
      final value = result.getOrElse((_) => throw StateError('expected right'));
      expect(value.x, closeTo(35, 1e-9));
      expect(value.steps, isNotEmpty);
    });

    test('solves inverse rule of three', () async {
      final result = await repo
          .solve(
            const RuleOfThreeInput(
              a: 3,
              b: 12,
              c: 4,
              kind: RuleOfThreeKind.inverse,
            ),
          )
          .run();
      final value = result.getOrElse((_) => throw StateError('expected right'));
      expect(value.x, closeTo(9, 1e-9));
    });

    test('fails when a is zero', () async {
      final result = await repo
          .solve(
            const RuleOfThreeInput(
              a: 0,
              b: 10,
              c: 5,
              kind: RuleOfThreeKind.direct,
            ),
          )
          .run();
      final failure = result.getLeft().toNullable();
      expect(failure, isNotNull);
    });
  });
}
