import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../domain/entities/worksheet_entity.dart';
import '../../domain/repositories/worksheet_repository.dart';

class WorksheetDetailCubit extends Cubit<ResourceState<WorksheetEntity>> {
  final WorksheetRepository _repository;
  WorksheetDetailCubit(this._repository) : super(const ResourceLoading());

  Future<void> load(int id) async {
    emit(const ResourceLoading());
    final result = await _repository.getById(id);
    result.fold(
      (failure) => emit(ResourceError(failure.message)),
      (data) => emit(ResourceLoaded(data)),
    );
  }
}
