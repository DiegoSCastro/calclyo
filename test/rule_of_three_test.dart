import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ruleOfThreeDefinition', () {
    test('exposes the expected id, name, route, and category', () {
      expect(ruleOfThreeDefinition.id, 'rule-of-three');
      expect(ruleOfThreeDefinition.route, '/rule-of-three');
      expect(ruleOfThreeDefinition.name, 'Rule of Three');
      expect(ruleOfThreeDefinition.inputSchema.fields.length, 3);
      expect(ruleOfThreeDefinition.inputSchema.controls.length, 1);
    });
  });

  group('ruleOfThreeDefinition.compute', () {
    final compute = ruleOfThreeDefinition.compute;

    Future<double> solve({
      required double a,
      required double b,
      required double c,
      required RuleOfThreeKind kind,
    }) async {
      final kindValue = kind == RuleOfThreeKind.direct ? 'Direct' : 'Inverse';
      final result = await compute({
        'a': a.toString(),
        'b': b.toString(),
        'c': c.toString(),
        'kind': kindValue,
      }).run();
      return result
          .getOrElse((f) => throw StateError('expected right, got failure: $f'))
          .primary;
    }

    test('solves the direct proportion x = (b × c) / a', () async {
      // 2:10 :: 7:x → x = 70/2 = 35
      expect(
        await solve(a: 2, b: 10, c: 7, kind: RuleOfThreeKind.direct),
        closeTo(35, 1e-9),
      );
    });

    test('solves the inverse proportion x = (a × b) / c', () async {
      // 3:12 :: 4:x → x = 36/4 = 9
      expect(
        await solve(a: 3, b: 12, c: 4, kind: RuleOfThreeKind.inverse),
        closeTo(9, 1e-9),
      );
    });

    test('fails when a is zero', () async {
      final result = await compute({
        'a': '0',
        'b': '10',
        'c': '5',
        'kind': 'Direct',
      }).run();
      expect(result.isLeft(), isTrue);
      final failure = result.getLeft().toNullable();
      expect(failure, isNotNull);
    });

    test('defaults to direct when the kind toggle is absent', () async {
      // No 'kind' key → treated as direct.
      final result = await compute({'a': '2', 'b': '10', 'c': '7'}).run();
      final value = result.getOrElse(
        (f) => throw StateError('expected right, got failure: $f'),
      );
      expect(value.primary, closeTo(35, 1e-9));
    });
  });
}
