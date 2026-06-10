import 'package:calclyo/app/app.dart';
import 'package:calclyo/src/features/category/data/category_repository.dart';
import 'package:calclyo/src/features/rule_of_three/data/rule_of_three_repository.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    CalclyoApp(
      categoryRepository: CategoryRepository(),
      ruleOfThreeRepository: RuleOfThreeRepository(),
    ),
  );
}
