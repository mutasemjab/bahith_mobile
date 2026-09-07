import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/course_repository.dart';
import 'course_activation_state.dart';

class CourseActivationCubit extends Cubit<CourseActivationState> {
  final CourseRepository _repository;
  CourseActivationCubit(this._repository)
    : super(const CourseActivationInitial());

  Future<void> activate({
    required int courseId,
    required String cardCode,
  }) async {
    emit(const CourseActivationLoading());
    final result = await _repository.activateCourse(
      courseId: courseId,
      cardCode: cardCode,
    );
    result.fold(
      (failure) => emit(CourseActivationError(failure.message)),
      (_) => emit(const CourseActivationSuccess()),
    );
  }
}
