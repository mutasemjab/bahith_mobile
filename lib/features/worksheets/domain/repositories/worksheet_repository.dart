import '../../../../core/api/api_result.dart';
import '../../../../core/utils/pagination.dart';
import '../entities/worksheet_entity.dart';

abstract class WorksheetRepository {
  ApiResult<PaginatedResult<WorksheetEntity>> getAll({
    required int page,
    int? subjectId,
    int? year,
    String? search,
  });

  ApiResult<WorksheetEntity> getById(int id);
}
