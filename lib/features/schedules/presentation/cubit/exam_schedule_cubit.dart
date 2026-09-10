import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/repositories/schedule_repository.dart';

class ExamScheduleCubit extends Cubit<ResourceState<ScheduleEntity?>> {
  final ScheduleRepository _repository;
  ExamScheduleCubit(this._repository) : super(const ResourceLoading());

  Future<void> load() async {
    emit(const ResourceLoading());
    final result = await _repository.getExamSchedule();
    result.fold(
      (failure) => emit(ResourceError(failure.message)),
      (schedule) => emit(ResourceLoaded(schedule)),
    );
  }
}
