import 'package:calclyo/app/app.dart';
import 'package:calclyo/src/features/category/data/category_repository.dart';
import 'package:calclyo/src/features/rule_of_three/data/rule_of_three_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Calclyo app boots to category list', (tester) async {
    await tester.pumpWidget(
      CalclyoApp(
        categoryRepository: const CategoryRepository(),
        ruleOfThreeRepository: const RuleOfThreeRepository(),
      ),
    );
    await tester.pump();
    expect(find.text('Calclyo'), findsOneWidget);
  });
}
