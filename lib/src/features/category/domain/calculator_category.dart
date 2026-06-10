import 'package:equatable/equatable.dart';

enum CategoryId {
  math,
  geometry,
  finance,
  health,
  converter,
  everyday,
  science,
}

class CalculatorCategory extends Equatable {
  const CalculatorCategory({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.description,
    required this.calculators,
  });

  final CategoryId id;
  final String name;
  final int iconCodePoint;
  final String description;
  final List<CalculatorEntry> calculators;

  @override
  List<Object?> get props => [id, name, iconCodePoint, description, calculators];
}

class CalculatorEntry extends Equatable {
  const CalculatorEntry({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.route,
  });

  final String id;
  final String name;
  final String subtitle;
  final String route;

  @override
  List<Object?> get props => [id, name, subtitle, route];
}
