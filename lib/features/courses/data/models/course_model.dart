import '../../../../core/utils/json_parsing.dart';
import '../../domain/entities/course_entity.dart';

int? _relatedId(dynamic value) {
  if (value is Map) return value['id'] as int?;
  return null;
}

/// `/courses/{id}` has reported an enrolled student's progress under
/// different keys than the flat `progress` fraction `/my-courses` uses —
/// fall back to any percentage-style field we've seen from this API.
double? _progressFraction(Map<String, dynamic> json) {
  final percentage =
      toDoubleOrNull(json['progress_percentage']) ??
      toDoubleOrNull(json['completion_percentage']);
  if (percentage == null) return null;
  return percentage / 100;
}

class CourseLessonModel extends CourseLessonEntity {
  const CourseLessonModel({
    required super.id,
    required super.title,
    super.durationMinutes,
    super.isFree,
    super.isCompleted,
  });

  factory CourseLessonModel.fromJson(Map<String, dynamic> json) =>
      CourseLessonModel(
        id: json['id'],
        title: json['title'] ?? '',
        durationMinutes: json['duration_minutes'],
        isFree: json['is_free'] ?? false,
        isCompleted: json['is_completed'] ?? false,
      );
}

class CourseUnitModel extends CourseUnitEntity {
  const CourseUnitModel({
    required super.id,
    required super.title,
    super.lessons,
  });

  factory CourseUnitModel.fromJson(Map<String, dynamic> json) =>
      CourseUnitModel(
        id: json['id'],
        title: json['title'] ?? '',
        lessons: (json['lessons'] as List<dynamic>? ?? [])
            .map((e) => CourseLessonModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.title,
    super.description,
    super.image,
    super.teacherId,
    super.teacherName,
    super.teacherAvatar,
    super.categoryName,
    super.subjectName,
    super.price,
    super.oldPrice,
    super.discountPercent,
    super.isFree,
    super.rating,
    super.studentsCount,
    super.lessonsCount,
    super.durationHours,
    super.difficultyLevel,
    super.featured,
    super.trending,
    super.isEnrolled,
    super.progress,
    super.units,
    super.canPurchaseViaStore,
  });

  factory CourseModel.fromJson(
    Map<String, dynamic> json, {
    bool? featured,
    bool? trending,
  }) {
    final teacher = json['teacher'];
    final subject = json['subject'];
    final price = toDoubleOrNull(json['price']);
    final isFree = json['is_free'] ?? (price == null || price == 0);

    return CourseModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      image: json['thumbnail'] ?? json['image'],
      teacherId: _relatedId(teacher) ?? json['teacher_id'],
      teacherName: relatedName(teacher) ?? json['teacher_name'],
      teacherAvatar: teacher is Map ? teacher['avatar'] as String? : null,
      categoryName: relatedName(json['category']) ?? json['category_name'],
      subjectName: relatedName(subject) ?? json['subject_name'],
      price: price,
      oldPrice: toDoubleOrNull(json['old_price']),
      discountPercent: json['discount'],
      isFree: isFree,
      canPurchaseViaStore: json['can_purchase_via_store'] ?? !isFree,
      rating: toDouble(json['average_rating'] ?? json['rating']),
      studentsCount: json['total_students'] ?? json['students_count'] ?? 0,
      lessonsCount: json['lessons_count'] ?? 0,
      durationHours: toDoubleOrNull(json['duration_hours']),
      difficultyLevel: json['difficulty_level'],
      featured: featured ?? json['featured'] ?? json['is_featured'] ?? false,
      trending: trending ?? json['trending'] ?? json['is_trending'] ?? false,
      isEnrolled: json['is_enrolled'] ?? (json['progress'] != null),
      progress: toDoubleOrNull(json['progress']) ?? _progressFraction(json),
      units: (json['units'] as List<dynamic>? ?? [])
          .map((e) => CourseUnitModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
