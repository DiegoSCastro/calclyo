import 'package:calclyo/src/features/category/data/category_repository.dart';
import 'package:calclyo/src/features/category/presentation/cubit/category_cubit.dart';
import 'package:calclyo/src/features/rule_of_three/data/rule_of_three_repository.dart';
import 'package:calclyo/src/features/rule_of_three/presentation/cubit/rule_of_three_cubit.dart';
import 'package:calclyo/src/router/app_router.dart';
import 'package:calclyo/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalclyoApp extends StatelessWidget {
  const CalclyoApp({
    required this.categoryRepository,
    required this.ruleOfThreeRepository,
    super.key,
  });

  final CategoryRepository categoryRepository;
  final RuleOfThreeRepository ruleOfThreeRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: categoryRepository),
        RepositoryProvider.value(value: ruleOfThreeRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => CategoryCubit(categoryRepository)..load(),
          ),
        ],
        child: MaterialApp.router(
          title: 'Calclyo',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          routerConfig: AppRouter.config,
        ),
      ),
    );
  }
}
