import 'package:dartz/dartz.dart';

import '../../../../core/cubit/paginated_cubit.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/pagination.dart';
import '../../domain/entities/worksheet_entity.dart';
import '../../domain/repositories/worksheet_repository.dart';

class WorksheetsCubit extends PaginatedCubit<WorksheetEntity> {
  final WorksheetRepository _repository;
  String? searchQuery;
  int? classId;
  int? year;
  int? subjectId;

  WorksheetsCubit(this._repository);

  void search(String query) {
    searchQuery = query;
    loadFirstPage();
  }

  @override
  Future<Either<Failure, PaginatedResult<WorksheetEntity>>> fetchPage(
    int page,
  ) => _repository.getAll(
    page: page,
    classId: classId,
    subjectId: subjectId,
    year: year,
    search: searchQuery,
  );
}
