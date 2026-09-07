import 'package:dartz/dartz.dart';

import '../../../../core/cubit/paginated_cubit.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/pagination.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/repositories/course_repository.dart';

class CoursesCubit extends PaginatedCubit<CourseEntity> {
  final CourseRepository _repository;
  CourseFilters filters;

  CoursesCubit(this._repository, {this.filters = const CourseFilters()});

  void applyFilters(CourseFilters newFilters) {
    filters = newFilters;
    loadFirstPage();
  }

  void search(String query) {
    filters = CourseFilters(
      categoryId: filters.categoryId,
      subjectId: filters.subjectId,
      teacherId: filters.teacherId,
      featured: filters.featured,
      trending: filters.trending,
      search: query,
    );
    loadFirstPage();
  }

  @override
  Future<Either<Failure, PaginatedResult<CourseEntity>>> fetchPage(int page) =>
      _repository.getCourses(page: page, filters: filters);
}
