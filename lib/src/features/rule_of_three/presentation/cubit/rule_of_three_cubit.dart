import 'package:calclyo/src/features/rule_of_three/data/rule_of_three_repository.dart';
import 'package:calclyo/src/features/rule_of_three/domain/rule_of_three_input.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

sealed class RuleOfThreeState extends Equatable {
  const RuleOfThreeState();
}

class RuleOfThreeInitial extends RuleOfThreeState {
  const RuleOfThreeInitial();
  @override
  List<Object?> get props => const [];
}

class RuleOfThreeSolved extends RuleOfThreeState {
  const RuleOfThreeSolved(this.result);
  final RuleOfThreeResult result;
  @override
  List<Object?> get props => [result];
}

class RuleOfThreeFailed extends RuleOfThreeState {
  const RuleOfThreeFailed(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class RuleOfThreeCubit extends Cubit<RuleOfThreeState> {
  RuleOfThreeCubit(this._repository) : super(const RuleOfThreeInitial());

  final RuleOfThreeRepository _repository;

  Future<void> solve(RuleOfThreeInput input) async {
    final TaskEither<RuleOfThreeRepositoryFailure, RuleOfThreeResult> task =
        _repository.solve(input);
    final Either<RuleOfThreeRepositoryFailure, RuleOfThreeResult> result =
        await task.run();
    result.fold(
      (failure) => emit(RuleOfThreeFailed(failure.message)),
      (value) => emit(RuleOfThreeSolved(value)),
    );
  }
}
