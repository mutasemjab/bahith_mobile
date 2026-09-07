import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/repositories/course_repository.dart';

class CourseDetailCubit extends Cubit<ResourceState<CourseEntity>> {
  final CourseRepository _repository;
  CourseDetailCubit(this._repository) : super(const ResourceLoading());

  Future<void> load(int id) async {
    emit(const ResourceLoading());
    final result = await _repository.getCourse(id);
    result.fold(
      (failure) => emit(ResourceError(failure.message)),
      (course) => emit(ResourceLoaded(course)),
    );
  }

  /// Optimistically flips the locally-held course to enrolled right after a
  /// successful activation, instead of trusting a re-fetch to report it —
  /// `/courses/{id}` doesn't reliably reflect `is_enrolled` immediately.
  void markEnrolled() {
    final current = state;
    if (current is ResourceLoaded<CourseEntity>) {
      emit(
        ResourceLoaded(
          current.data.copyWith(
            isEnrolled: true,
            progress: current.data.progress ?? 0,
          ),
        ),
      );
    }
  }
}
