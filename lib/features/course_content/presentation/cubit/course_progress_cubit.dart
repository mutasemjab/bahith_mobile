import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../domain/entities/course_content_entity.dart';
import '../../domain/repositories/course_content_repository.dart';

class CourseProgressCubit extends Cubit<ResourceState<CourseProgressEntity>> {
  final CourseContentRepository _repository;
  CourseProgressCubit(this._repository) : super(const ResourceLoading());

  Future<void> load(int courseId) async {
    emit(const ResourceLoading());
    final result = await _repository.getCourseProgress(courseId);
    result.fold(
      (failure) => emit(ResourceError(failure.message)),
      (progress) => emit(ResourceLoaded(progress)),
    );
  }
}
