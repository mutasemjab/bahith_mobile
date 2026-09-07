import '../../../../core/api/api_result.dart';
import '../../../../core/utils/pagination.dart';
import '../entities/exam_entity.dart';

class ExamFilters {
  final int? courseId;
  final int? subjectId;
  final String? examType;
  final String? search;

  const ExamFilters({
    this.courseId,
    this.subjectId,
    this.examType,
    this.search,
  });

  Map<String, dynamic> toQuery() => {
    if (courseId != null) 'course_id': courseId,
    if (subjectId != null) 'subject_id': subjectId,
    if (examType != null) 'exam_type': examType,
    if (search != null && search!.isNotEmpty) 'search': search,
  };
}

abstract class ExamRepository {
  ApiResult<PaginatedResult<ExamEntity>> getExams({
    required int page,
    ExamFilters filters = const ExamFilters(),
  });

  ApiResult<ExamEntity> getExam(int id);

  ApiResult<int> startExam(int id);

  ApiResult<ExamResultEntity> submitAttempt({
    required int attemptId,
    required Map<int, int> answers,
  });
}
