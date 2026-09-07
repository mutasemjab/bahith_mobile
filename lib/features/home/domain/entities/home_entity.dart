import 'package:equatable/equatable.dart';

import '../../../categories/domain/entities/category_entity.dart';
import '../../../courses/domain/entities/course_entity.dart';
import '../../../teachers/domain/entities/teacher_entity.dart';

class HomeStatsEntity extends Equatable {
  final int studentsCount;
  final int coursesCount;
  final int teachersCount;
  final int examsCount;

  const HomeStatsEntity({
    this.studentsCount = 0,
    this.coursesCount = 0,
    this.teachersCount = 0,
    this.examsCount = 0,
  });

  @override
  List<Object?> get props => [
    studentsCount,
    coursesCount,
    teachersCount,
    examsCount,
  ];
}

class HomeEntity extends Equatable {
  final List<CategoryEntity> categories;
  final List<CourseEntity> featuredCourses;
  final List<CourseEntity> trendingCourses;
  final List<TeacherEntity> topTeachers;
  final HomeStatsEntity stats;

  const HomeEntity({
    required this.categories,
    required this.featuredCourses,
    required this.trendingCourses,
    required this.topTeachers,
    required this.stats,
  });

  @override
  List<Object?> get props => [
    categories,
    featuredCourses,
    trendingCourses,
    topTeachers,
    stats,
  ];
}
