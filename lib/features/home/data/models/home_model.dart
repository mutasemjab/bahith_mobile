import '../../../categories/data/models/category_model.dart';
import '../../../courses/data/models/course_model.dart';
import '../../../teachers/data/models/teacher_model.dart';
import '../../domain/entities/home_entity.dart';

class HomeStatsModel extends HomeStatsEntity {
  const HomeStatsModel({
    super.studentsCount,
    super.coursesCount,
    super.teachersCount,
    super.examsCount,
  });

  factory HomeStatsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HomeStatsModel();
    return HomeStatsModel(
      studentsCount: json['total_students'] ?? json['students_count'] ?? 0,
      coursesCount: json['total_courses'] ?? json['courses_count'] ?? 0,
      teachersCount: json['total_teachers'] ?? json['teachers_count'] ?? 0,
      examsCount: json['total_exams'] ?? json['exams_count'] ?? 0,
    );
  }
}

class HomeModel extends HomeEntity {
  const HomeModel({
    required super.categories,
    required super.featuredCourses,
    required super.trendingCourses,
    required super.topTeachers,
    required super.stats,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) => HomeModel(
    categories: (json['categories'] as List<dynamic>? ?? [])
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    featuredCourses: (json['featured_courses'] as List<dynamic>? ?? [])
        .map(
          (e) =>
              CourseModel.fromJson(e as Map<String, dynamic>, featured: true),
        )
        .toList(),
    trendingCourses: (json['trending_courses'] as List<dynamic>? ?? [])
        .map(
          (e) =>
              CourseModel.fromJson(e as Map<String, dynamic>, trending: true),
        )
        .toList(),
    topTeachers: (json['top_teachers'] as List<dynamic>? ?? [])
        .map((e) => TeacherModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    stats: HomeStatsModel.fromJson(json['stats'] as Map<String, dynamic>?),
  );
}
