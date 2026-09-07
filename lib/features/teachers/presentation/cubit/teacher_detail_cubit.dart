import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../domain/entities/teacher_detail_entity.dart';
import '../../domain/repositories/teacher_repository.dart';

class TeacherDetailCubit extends Cubit<ResourceState<TeacherDetailEntity>> {
  final TeacherRepository _repository;
  TeacherDetailCubit(this._repository) : super(const ResourceLoading());

  Future<void> load(int id) async {
    emit(const ResourceLoading());
    final result = await _repository.getTeacher(id);
    result.fold(
      (failure) => emit(ResourceError(failure.message)),
      (detail) => emit(ResourceLoaded(detail)),
    );
  }
}
