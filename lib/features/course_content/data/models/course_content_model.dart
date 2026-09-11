import '../../../../core/utils/json_parsing.dart';
import '../../domain/entities/course_content_entity.dart';

class ContentUnitExamModel extends ContentUnitExamEntity {
  const ContentUnitExamModel({
    required super.id,
    required super.title,
    super.durationMinutes,
    super.totalQuestions,
  });

  factory ContentUnitExamModel.fromJson(Map<String, dynamic> json) =>
      ContentUnitExamModel(
        id: json['id'],
        title: json['title'] ?? '',
        durationMinutes: json['duration_minutes'],
        totalQuestions: json['total_questions'] ?? 0,
      );
}

class ContentLessonModel extends ContentLessonEntity {
  const ContentLessonModel({
    required super.id,
    required super.title,
    required super.lessonType,
    super.durationMinutes,
    super.orderIndex,
    super.isFree,
    super.isLocked,
    super.isLockedBySequence,
    super.videoUrl,
    super.fileUrl,
  });

  factory ContentLessonModel.fromJson(Map<String, dynamic> json) =>
      ContentLessonModel(
        id: json['id'],
        title: json['title'] ?? '',
        lessonType: json['lesson_type'] ?? 'video',
        durationMinutes: json['duration_minutes'],
        orderIndex: json['order_index'] ?? 0,
        isFree: json['is_free'] ?? false,
        isLocked: json['is_locked'] ?? false,
        isLockedBySequence: json['is_locked_by_sequence'] ?? false,
        videoUrl: json['video_url'],
        fileUrl: json['file_url'],
      );
}

class ContentUnitModel extends ContentUnitEntity {
  const ContentUnitModel({
    required super.id,
    required super.title,
    super.description,
    super.orderIndex,
    super.lessons,
    super.exams,
  });

  factory ContentUnitModel.fromJson(Map<String, dynamic> json) =>
      ContentUnitModel(
        id: json['id'],
        title: json['title'] ?? '',
        description: json['description'],
        orderIndex: json['order_index'] ?? 0,
        lessons: (json['lessons'] as List<dynamic>? ?? [])
            .map((e) => ContentLessonModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        exams: (json['exams'] as List<dynamic>? ?? [])
            .map(
              (e) => ContentUnitExamModel.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
}

class CourseContentModel extends CourseContentEntity {
  const CourseContentModel({
    required super.courseId,
    required super.courseName,
    required super.isEnrolled,
    super.units,
  });

  factory CourseContentModel.fromJson(Map<String, dynamic> json) =>
      CourseContentModel(
        courseId: json['course_id'],
        courseName: json['course_name'] ?? '',
        isEnrolled: json['is_enrolled'] ?? false,
        units: (json['units'] as List<dynamic>? ?? [])
            .map((e) => ContentUnitModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class LessonDetailModel extends LessonDetailEntity {
  const LessonDetailModel({
    required super.id,
    required super.title,
    required super.lessonType,
    super.videoUrl,
    super.fileUrl,
    super.durationMinutes,
    super.isFree,
    super.unitId,
    super.courseId,
  });

  factory LessonDetailModel.fromJson(Map<String, dynamic> json) =>
      LessonDetailModel(
        id: json['id'],
        title: json['title'] ?? '',
        lessonType: json['lesson_type'] ?? 'video',
        videoUrl: json['video_url'],
        fileUrl: json['file_url'],
        durationMinutes: json['duration_minutes'],
        isFree: json['is_free'] ?? false,
        unitId: json['unit_id'],
        courseId: json['course_id'],
      );
}

class LessonWatchPositionModel extends LessonWatchPositionEntity {
  const LessonWatchPositionModel({
    required super.watchSeconds,
    super.isCompleted,
  });

  factory LessonWatchPositionModel.fromJson(Map<String, dynamic> json) =>
      LessonWatchPositionModel(
        watchSeconds: toInt(json['watch_seconds']),
        isCompleted: json['is_completed'] == true,
      );
}

class CourseProgressModel extends CourseProgressEntity {
  const CourseProgressModel({
    required super.courseId,
    required super.percentage,
    super.completedLessons,
    super.totalLessons,
    super.completedExams,
    super.totalExams,
    super.completedLessonIds,
    super.watchPositions,
  });

  factory CourseProgressModel.fromJson(Map<String, dynamic> json) {
    // When there are no watch positions yet, this endpoint sends `[]`
    // (an empty array) instead of `{}` — only trust it as a map when it
    // actually is one.
    final rawPositions = json['watch_positions'];
    final positionsJson = rawPositions is Map<String, dynamic>
        ? rawPositions
        : <String, dynamic>{};
    return CourseProgressModel(
      courseId: toInt(json['course_id']),
      percentage: toInt(json['percentage']),
      completedLessons: toInt(json['completed_lessons']),
      totalLessons: toInt(json['total_lessons']),
      completedExams: toInt(json['completed_exams']),
      totalExams: toInt(json['total_exams']),
      completedLessonIds:
          (json['completed_lesson_ids'] is List
                  ? json['completed_lesson_ids'] as List<dynamic>
                  : <dynamic>[])
              .map(toInt)
              .toList(),
      watchPositions: positionsJson.map(
        (key, value) => MapEntry(
          int.tryParse(key) ?? 0,
          LessonWatchPositionModel.fromJson(value as Map<String, dynamic>),
        ),
      ),
    );
  }
}

class LessonProgressResultModel extends LessonProgressResultEntity {
  const LessonProgressResultModel({
    required super.lessonId,
    required super.watchSeconds,
    required super.isCompleted,
    super.coursePercentage,
  });

  factory LessonProgressResultModel.fromJson(Map<String, dynamic> json) {
    final courseProgress = json['course_progress'];
    return LessonProgressResultModel(
      lessonId: toInt(json['lesson_id']),
      watchSeconds: toInt(json['watch_seconds']),
      isCompleted: json['is_completed'] == true,
      coursePercentage: courseProgress is Map
          ? toIntOrNull(courseProgress['percentage'])
          : null,
    );
  }
}
