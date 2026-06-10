import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';

/// The single list of every calculator the app exposes.
///
/// Adding a new calculator = write a new file under
/// `lib/src/calculators/<id>/<id>.dart`, append the const definition here.
/// The router, home screen, and (eventually) search all read from this list.
const calculators = <CalculatorDefinition>[
  ruleOfThreeDefinition,
];

/// The app's [CategoryRegistry], pre-populated with [calculators].
final calculatorRegistry = CategoryRegistry(calculators);
