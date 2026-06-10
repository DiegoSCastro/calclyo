import 'package:calclyo/src/calculators/acceleration/acceleration.dart';
import 'package:calclyo/src/calculators/age/age.dart';
import 'package:calclyo/src/calculators/angle/angle.dart';
import 'package:calclyo/src/calculators/area/area.dart';
import 'package:calclyo/src/calculators/average/average.dart';
import 'package:calclyo/src/calculators/bmi/bmi.dart';
import 'package:calclyo/src/calculators/bodies_3d/bodies_3d.dart';
import 'package:calclyo/src/calculators/body_fat/body_fat.dart';
import 'package:calclyo/src/calculators/caloric_burn/caloric_burn.dart';
import 'package:calclyo/src/calculators/circle/circle.dart';
import 'package:calclyo/src/calculators/clothing_size/clothing_size.dart';
import 'package:calclyo/src/calculators/combinations/combinations.dart';
import 'package:calclyo/src/calculators/cooking_volume/cooking_volume.dart';
import 'package:calclyo/src/calculators/data_storage/data_storage.dart';
import 'package:calclyo/src/calculators/data_transfer/data_transfer.dart';
import 'package:calclyo/src/calculators/date_add_subtract/date_add_subtract.dart';
import 'package:calclyo/src/calculators/discount/discount.dart';
import 'package:calclyo/src/calculators/energy/energy.dart';
import 'package:calclyo/src/calculators/equations/equations.dart';
import 'package:calclyo/src/calculators/force/force.dart';
import 'package:calclyo/src/calculators/fuel/fuel.dart';
import 'package:calclyo/src/calculators/gcf_lcm/gcf_lcm.dart';
import 'package:calclyo/src/calculators/length/length.dart';
import 'package:calclyo/src/calculators/loan_pmt/loan_pmt.dart';
import 'package:calclyo/src/calculators/mileage/mileage.dart';
import 'package:calclyo/src/calculators/number_generator/number_generator.dart';
import 'package:calclyo/src/calculators/numeric_base/numeric_base.dart';
import 'package:calclyo/src/calculators/ohms_law/ohms_law.dart';
import 'package:calclyo/src/calculators/percentage/percentage.dart';
import 'package:calclyo/src/calculators/polygon/polygon.dart';
import 'package:calclyo/src/calculators/power/power.dart';
import 'package:calclyo/src/calculators/prime_check/prime_check.dart';
import 'package:calclyo/src/calculators/proportion/proportion.dart';
import 'package:calclyo/src/calculators/ratio/ratio.dart';
import 'package:calclyo/src/calculators/rectangle/rectangle.dart';
import 'package:calclyo/src/calculators/roman_numerals/roman_numerals.dart';
import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart';
import 'package:calclyo/src/calculators/sales_tax/sales_tax.dart';
import 'package:calclyo/src/calculators/shoe_size/shoe_size.dart';
import 'package:calclyo/src/calculators/speed/speed.dart';
import 'package:calclyo/src/calculators/temperature_converter/temperature_converter.dart';
import 'package:calclyo/src/calculators/time_interval/time_interval.dart';
import 'package:calclyo/src/calculators/tip/tip.dart';
import 'package:calclyo/src/calculators/triangle/triangle.dart';
import 'package:calclyo/src/calculators/unit_price/unit_price.dart';
import 'package:calclyo/src/calculators/weight/weight.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';

/// The single list of every calculator the app exposes.
///
/// Adding a new calculator = write a new file under
/// `lib/src/calculators/<id>/<id>.dart`, append the const definition here.
/// The router, home screen, and (eventually) search all read from this list.
const calculators = <CalculatorDefinition>[
  // Algebra
  ruleOfThreeDefinition,
  percentageDefinition,
  averageDefinition,
  proportionDefinition,
  ratioDefinition,
  equationsDefinition,
  gcfLcmDefinition,
  combinationsDefinition,
  primeCheckDefinition,
  numberGeneratorDefinition,

  // Geometry
  triangleDefinition,
  circleDefinition,
  rectangleDefinition,
  polygonDefinition,
  bodies3DDefinition,

  // Unit converters (physical)
  lengthDefinition,
  areaDefinition,
  cookingVolumeDefinition,
  dataStorageDefinition,
  dataTransferDefinition,
  energyDefinition,
  forceDefinition,
  fuelDefinition,
  accelerationDefinition,
  angleDefinition,
  numericBaseDefinition,
  powerDefinition,
  temperatureConverterDefinition,
  weightDefinition,
  speedDefinition,

  // Lifestyle
  romanNumeralsDefinition,
  shoeSizeDefinition,
  clothingSizeDefinition,

  // Finance
  unitPriceDefinition,
  salesTaxDefinition,
  tipDefinition,
  discountDefinition,
  loanPmtDefinition,

  // Health
  bmiDefinition,
  bodyFatDefinition,
  caloricBurnDefinition,

  // Date & time
  ageDefinition,
  dateAddSubtractDefinition,
  timeIntervalDefinition,

  // Science
  ohmsLawDefinition,
  mileageDefinition,
];

/// The app's [CategoryRegistry], pre-populated with [calculators].
const calculatorRegistry = CategoryRegistry(calculators);
