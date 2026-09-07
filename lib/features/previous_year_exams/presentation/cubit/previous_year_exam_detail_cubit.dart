import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../domain/entities/previous_year_exam_entity.dart';
import '../../domain/repositories/previous_year_exam_repository.dart';

class PreviousYearExamDetailCubit
    extends Cubit<ResourceState<PreviousYearExamEntity>> {
  final PreviousYearExamRepository _repository;
  PreviousYearExamDetailCubit(this._repository)
    : super(const ResourceLoading());

  Future<void> load(int id) async {
    emit(const ResourceLoading());
    final result = await _repository.getById(id);
    result.fold(
      (failure) => emit(ResourceError(failure.message)),
      (data) => emit(ResourceLoaded(data)),
    );
  }
}
