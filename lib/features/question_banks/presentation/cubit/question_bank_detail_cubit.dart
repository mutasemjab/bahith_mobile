import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../domain/entities/question_bank_entity.dart';
import '../../domain/repositories/question_bank_repository.dart';

class QuestionBankDetailCubit extends Cubit<ResourceState<QuestionBankEntity>> {
  final QuestionBankRepository _repository;
  QuestionBankDetailCubit(this._repository) : super(const ResourceLoading());

  Future<void> load(int id) async {
    emit(const ResourceLoading());
    final result = await _repository.getById(id);
    result.fold(
      (failure) => emit(ResourceError(failure.message)),
      (data) => emit(ResourceLoaded(data)),
    );
  }
}
