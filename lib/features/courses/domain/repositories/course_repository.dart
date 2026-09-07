import '../../../../core/api/api_result.dart';
import '../../../../core/utils/pagination.dart';
import '../entities/course_entity.dart';

class CourseFilters {
  final int? categoryId;
  final int? subjectId;
  final int? teacherId;
  final String? search;
  final bool? featured;
  final bool? trending;

  const CourseFilters({
    this.categoryId,
    this.subjectId,
    this.teacherId,
    this.search,
    this.featured,
    this.trending,
  });

  Map<String, dynamic> toQuery() => {
    if (categoryId != null) 'category_id': categoryId,
    if (subjectId != null) 'subject_id': subjectId,
    if (teacherId != null) 'teacher_id': teacherId,
    if (search != null && search!.isNotEmpty) 'search': search,
    if (featured == true) 'featured': 1,
    if (trending == true) 'trending': 1,
  };
}

abstract class CourseRepository {
  ApiResult<PaginatedResult<CourseEntity>> getCourses({
    required int page,
    CourseFilters filters = const CourseFilters(),
  });

  ApiResult<CourseEntity> getCourse(int id);

  ApiResult<void> activateCourse({
    required int courseId,
    required String cardCode,
  });
}
