import '../../../../core/api/api_result.dart';
import '../../../../core/utils/pagination.dart';
import '../entities/question_bank_entity.dart';

abstract class QuestionBankRepository {
  ApiResult<PaginatedResult<QuestionBankEntity>> getAll({
    required int page,
    int? subjectId,
    String? search,
  });

  ApiResult<QuestionBankEntity> getById(int id);
}
