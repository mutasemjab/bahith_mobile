import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../domain/entities/course_content_entity.dart';
import '../../domain/repositories/course_content_repository.dart';

class LessonDetailCubit extends Cubit<ResourceState<LessonDetailEntity>> {
  final CourseContentRepository _repository;
  LessonDetailCubit(this._repository) : super(const ResourceLoading());

  Future<void> load(int lessonId) async {
    emit(const ResourceLoading());
    final result = await _repository.getLesson(lessonId);
    result.fold(
      (failure) => emit(ResourceError(failure.message)),
      (lesson) => emit(ResourceLoaded(lesson)),
    );
  }

  /// Periodic "still watching" ping. Best-effort — a dropped position
  /// update shouldn't interrupt playback or surface an error to the
  /// student, so failures are swallowed silently (the repository already
  /// maps them into a [Left] rather than throwing).
  Future<void> savePosition(int lessonId, int watchSeconds) async {
    if (watchSeconds <= 0) return;
    await _repository.saveLessonPosition(
      lessonId: lessonId,
      watchSeconds: watchSeconds,
    );
  }

  /// Sent once when the video ends. Returns the course's new completion
  /// percentage when the server reports one, so the caller can refresh
  /// anywhere else that shows it — null on failure (silent, same reasoning
  /// as [savePosition]).
  Future<int?> markCompleted(int lessonId, int watchSeconds) async {
    final result = await _repository.completeLesson(
      lessonId: lessonId,
      watchSeconds: watchSeconds,
    );
    return result.fold((_) => null, (data) => data.coursePercentage);
  }
}
