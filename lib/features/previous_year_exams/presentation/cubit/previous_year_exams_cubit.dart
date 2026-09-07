import 'package:dartz/dartz.dart';

import '../../../../core/cubit/paginated_cubit.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/pagination.dart';
import '../../domain/entities/previous_year_exam_entity.dart';
import '../../domain/repositories/previous_year_exam_repository.dart';

class PreviousYearExamsCubit extends PaginatedCubit<PreviousYearExamEntity> {
  final PreviousYearExamRepository _repository;
  String? searchQuery;
  int? year;
  int? subjectId;

  PreviousYearExamsCubit(this._repository);

  void search(String query) {
    searchQuery = query;
    loadFirstPage();
  }

  void filterByYear(int? y) {
    year = y;
    loadFirstPage();
  }

  @override
  Future<Either<Failure, PaginatedResult<PreviousYearExamEntity>>> fetchPage(
    int page,
  ) => _repository.getAll(
    page: page,
    subjectId: subjectId,
    year: year,
    search: searchQuery,
  );
}
