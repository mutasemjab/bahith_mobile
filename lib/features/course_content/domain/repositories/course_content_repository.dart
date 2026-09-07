import '../../../../core/api/api_result.dart';
import '../entities/course_content_entity.dart';

abstract class CourseContentRepository {
  ApiResult<CourseContentEntity> getCourseContent(int courseId);
  ApiResult<LessonDetailEntity> getLesson(int lessonId);

  /// Periodic "still watching" ping — no `is_completed` flag.
  ApiResult<void> saveLessonPosition({
    required int lessonId,
    required int watchSeconds,
  });

  /// Sent once, when the video ends — the response reports the course's
  /// new completion percentage if it changed.
  ApiResult<LessonProgressResultEntity> completeLesson({
    required int lessonId,
    required int watchSeconds,
  });

  ApiResult<CourseProgressEntity> getCourseProgress(int courseId);
}
