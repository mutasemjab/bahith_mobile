import '../../../../core/api/api_result.dart';
import '../../../../core/utils/pagination.dart';
import '../entities/previous_year_exam_entity.dart';

abstract class PreviousYearExamRepository {
  ApiResult<PaginatedResult<PreviousYearExamEntity>> getAll({
    required int page,
    int? subjectId,
    int? year,
    String? search,
  });

  ApiResult<PreviousYearExamEntity> getById(int id);
}
