import 'package:equatable/equatable.dart';

class ContentUnitExamEntity extends Equatable {
  final int id;
  final String title;
  final int? durationMinutes;
  final int totalQuestions;

  const ContentUnitExamEntity({
    required this.id,
    required this.title,
    this.durationMinutes,
    this.totalQuestions = 0,
  });

  @override
  List<Object?> get props => [id, title];
}

class ContentLessonEntity extends Equatable {
  final int id;
  final String title;
  final String lessonType;
  final int? durationMinutes;
  final int orderIndex;
  final bool isFree;
  final bool isLocked;
  final String? videoUrl;
  final String? fileUrl;

  const ContentLessonEntity({
    required this.id,
    required this.title,
    required this.lessonType,
    this.durationMinutes,
    this.orderIndex = 0,
    this.isFree = false,
    this.isLocked = false,
    this.videoUrl,
    this.fileUrl,
  });

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get hasFile => fileUrl != null && fileUrl!.isNotEmpty;

  @override
  List<Object?> get props => [id, title, isLocked];
}

class ContentUnitEntity extends Equatable {
  final int id;
  final String title;
  final String? description;
  final int orderIndex;
  final List<ContentLessonEntity> lessons;
  final List<ContentUnitExamEntity> exams;

  const ContentUnitEntity({
    required this.id,
    required this.title,
    this.description,
    this.orderIndex = 0,
    this.lessons = const [],
    this.exams = const [],
  });

  @override
  List<Object?> get props => [id, title, lessons, exams];
}

class CourseContentEntity extends Equatable {
  final int courseId;
  final String courseName;
  final bool isEnrolled;
  final List<ContentUnitEntity> units;

  const CourseContentEntity({
    required this.courseId,
    required this.courseName,
    required this.isEnrolled,
    this.units = const [],
  });

  CourseContentEntity copyWith({bool? isEnrolled}) {
    return CourseContentEntity(
      courseId: courseId,
      courseName: courseName,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      units: units,
    );
  }

  @override
  List<Object?> get props => [courseId, courseName, isEnrolled, units];
}

class LessonDetailEntity extends Equatable {
  final int id;
  final String title;
  final String lessonType;
  final String? videoUrl;
  final String? fileUrl;
  final int? durationMinutes;
  final bool isFree;
  final int? unitId;
  final int? courseId;

  const LessonDetailEntity({
    required this.id,
    required this.title,
    required this.lessonType,
    this.videoUrl,
    this.fileUrl,
    this.durationMinutes,
    this.isFree = false,
    this.unitId,
    this.courseId,
  });

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get hasFile => fileUrl != null && fileUrl!.isNotEmpty;

  @override
  List<Object?> get props => [id, title, videoUrl, fileUrl];
}

class LessonWatchPositionEntity extends Equatable {
  final int watchSeconds;
  final bool isCompleted;

  const LessonWatchPositionEntity({
    required this.watchSeconds,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props => [watchSeconds, isCompleted];
}

/// `/courses/{id}/my-progress` — the authoritative source for a course's
/// completion percentage and per-lesson watch state, keyed by lesson id.
class CourseProgressEntity extends Equatable {
  final int courseId;
  final int percentage;
  final int completedLessons;
  final int totalLessons;
  final int completedExams;
  final int totalExams;
  final List<int> completedLessonIds;
  final Map<int, LessonWatchPositionEntity> watchPositions;

  const CourseProgressEntity({
    required this.courseId,
    required this.percentage,
    this.completedLessons = 0,
    this.totalLessons = 0,
    this.completedExams = 0,
    this.totalExams = 0,
    this.completedLessonIds = const [],
    this.watchPositions = const {},
  });

  bool isLessonCompleted(int lessonId) => completedLessonIds.contains(lessonId);

  /// Seconds to resume a lesson's video from, or null if never watched.
  int? resumeSecondsFor(int lessonId) => watchPositions[lessonId]?.watchSeconds;

  @override
  List<Object?> get props => [
    courseId,
    percentage,
    completedLessons,
    totalLessons,
    completedLessonIds,
    watchPositions,
  ];
}

/// Result of `POST /lessons/{id}/progress` — `coursePercentage` is only
/// present when the call included `is_completed: true`.
class LessonProgressResultEntity extends Equatable {
  final int lessonId;
  final int watchSeconds;
  final bool isCompleted;
  final int? coursePercentage;

  const LessonProgressResultEntity({
    required this.lessonId,
    required this.watchSeconds,
    required this.isCompleted,
    this.coursePercentage,
  });

  @override
  List<Object?> get props => [
    lessonId,
    watchSeconds,
    isCompleted,
    coursePercentage,
  ];
}
