import 'package:dartz/dartz.dart';

import '../../../../core/cubit/paginated_cubit.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/pagination.dart';
import '../../domain/entities/exam_entity.dart';
import '../../domain/repositories/exam_repository.dart';

class ExamsCubit extends PaginatedCubit<ExamEntity> {
  final ExamRepository _repository;
  ExamFilters filters;

  ExamsCubit(this._repository, {this.filters = const ExamFilters()});

  void search(String query) {
    filters = ExamFilters(
      courseId: filters.courseId,
      subjectId: filters.subjectId,
      examType: filters.examType,
      search: query,
    );
    loadFirstPage();
  }

  @override
  Future<Either<Failure, PaginatedResult<ExamEntity>>> fetchPage(int page) =>
      _repository.getExams(page: page, filters: filters);
}
