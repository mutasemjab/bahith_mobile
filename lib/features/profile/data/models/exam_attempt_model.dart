import '../../../../core/utils/json_parsing.dart';
import '../../domain/entities/exam_attempt_entity.dart';

class ExamAttemptModel extends ExamAttemptEntity {
  const ExamAttemptModel({
    required super.id,
    required super.examTitle,
    required super.score,
    required super.percentage,
    required super.isPassed,
    super.submittedAt,
  });

  factory ExamAttemptModel.fromJson(Map<String, dynamic> json) {
    final exam = json['exam'];
    final title =
        (exam is Map ? exam['title'] : null) ??
        json['exam_title'] ??
        json['title'];
    return ExamAttemptModel(
      id: toInt(json['id']),
      examTitle: (title ?? '').toString(),
      score: toDouble(json['score']),
      percentage: toDouble(json['percentage']),
      isPassed:
          json['is_passed'] == true ||
          json['is_passed'] == 1 ||
          json['is_passed'] == '1',
      submittedAt: json['submitted_at']?.toString(),
    );
  }
}
