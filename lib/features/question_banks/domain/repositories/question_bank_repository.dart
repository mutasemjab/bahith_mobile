import '../../../../core/api/api_result.dart';
import '../../../../core/models/subject_ref.dart';
import '../../../../core/utils/pagination.dart';
import '../entities/question_bank_entity.dart';

abstract class QuestionBankRepository {
  ApiResult<PaginatedResult<QuestionBankEntity>> getAll({
    required int page,
    int? classId,
    int? subjectId,
    String? search,
  });

  ApiResult<QuestionBankEntity> getById(int id);

  /// Every distinct subject that has at least one question bank for
  /// [classId] — aggregated across all pages, since the list endpoint
  /// paginates. Drives the "pick a subject" screen.
  ApiResult<List<SubjectRef>> getSubjects({required int classId});
}
