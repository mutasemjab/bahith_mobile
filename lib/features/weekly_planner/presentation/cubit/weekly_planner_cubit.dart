import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../domain/entities/weekly_planner_entity.dart';
import '../../domain/repositories/weekly_planner_repository.dart';

class WeeklyPlannerCubit extends Cubit<ResourceState<WeeklyPlannerEntity?>> {
  final WeeklyPlannerRepository _repository;
  WeeklyPlannerCubit(this._repository) : super(const ResourceLoading());

  Future<void> load() async {
    emit(const ResourceLoading());
    final result = await _repository.getLatest();
    result.fold(
      (failure) => emit(ResourceError(failure.message)),
      (planner) => emit(ResourceLoaded(planner)),
    );
  }
}
