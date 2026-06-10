import 'package:calclyo/src/features/category/data/category_repository.dart';
import 'package:calclyo/src/features/category/domain/calculator_category.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

sealed class CategoryState extends Equatable {
  const CategoryState();
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
  @override
  List<Object?> get props => const [];
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
  @override
  List<Object?> get props => const [];
}

class CategoryLoaded extends CategoryState {
  const CategoryLoaded(this.categories);
  final List<CalculatorCategory> categories;
  @override
  List<Object?> get props => [categories];
}

class CategoryError extends CategoryState {
  const CategoryError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit(this._repository) : super(const CategoryInitial());

  final CategoryRepository _repository;

  Future<void> load() async {
    emit(const CategoryLoading());
    final TaskEither<CategoryRepositoryFailure, List<CalculatorCategory>>
        result = _repository.getCategories();
    final Either<CategoryRepositoryFailure, List<CalculatorCategory>>
        completed = await result.run();
    completed.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoryLoaded(categories)),
    );
  }
}
