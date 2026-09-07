import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../domain/entities/course_content_entity.dart';
import '../../domain/repositories/course_content_repository.dart';

class CourseContentCubit extends Cubit<ResourceState<CourseContentEntity>> {
  final CourseContentRepository _repository;
  CourseContentCubit(this._repository) : super(const ResourceLoading());

  Future<void> load(int courseId) async {
    emit(const ResourceLoading());
    final result = await _repository.getCourseContent(courseId);
    result.fold(
      (failure) => emit(ResourceError(failure.message)),
      (content) => emit(ResourceLoaded(content)),
    );
  }

  /// See [CourseDetailCubit.markEnrolled] — same API unreliability, applied
  /// here so the activation banner disappears reliably too.
  void markEnrolled() {
    final current = state;
    if (current is ResourceLoaded<CourseContentEntity>) {
      emit(ResourceLoaded(current.data.copyWith(isEnrolled: true)));
    }
  }
}
