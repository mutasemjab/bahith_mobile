import '../../../../core/utils/json_parsing.dart';
import '../../domain/entities/exam_entity.dart';

class ExamOptionModel extends ExamOptionEntity {
  const ExamOptionModel({
    required super.id,
    required super.text,
    super.isCorrect,
  });

  factory ExamOptionModel.fromJson(Map<String, dynamic> json) =>
      ExamOptionModel(
        id: json['id'],
        text: json['option_text'] ?? json['text'] ?? json['option'] ?? '',
        isCorrect: json['is_correct'],
      );
}

class ExamQuestionModel extends ExamQuestionEntity {
  const ExamQuestionModel({
    required super.id,
    required super.text,
    super.image,
    super.options,
  });

  factory ExamQuestionModel.fromJson(Map<String, dynamic> json) =>
      ExamQuestionModel(
        id: json['id'],
        text: json['question_text'] ?? json['text'] ?? json['question'] ?? '',
        image: json['image'],
        options: (json['options'] as List<dynamic>? ?? [])
            .map((e) => ExamOptionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ExamModel extends ExamEntity {
  const ExamModel({
    required super.id,
    required super.title,
    super.description,
    super.subjectName,
    super.examType,
    super.durationMinutes,
    super.questionsCount,
    super.passingScore,
    super.showResultImmediately,
    super.questions,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    final subject = json['subject'];
    final questions = (json['questions'] as List<dynamic>? ?? [])
        .map((e) => ExamQuestionModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return ExamModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      subjectName:
          (subject is Map ? subject['name'] : subject) ?? json['subject_name'],
      examType: json['exam_type'] ?? json['type'],
      durationMinutes: json['duration_minutes'],
      questionsCount:
          json['total_questions'] ??
          json['questions_count'] ??
          questions.length,
      passingScore: toDoubleOrNull(json['pass_marks'] ?? json['passing_score']),
      showResultImmediately: json['show_result_immediately'] ?? true,
      questions: questions,
    );
  }
}

class ExamResultModel extends ExamResultEntity {
  const ExamResultModel({
    required super.attemptId,
    required super.score,
    super.totalMarks,
    required super.percentage,
    required super.isPassed,
    super.correctAnswersCount,
    super.wrongAnswersCount,
    super.unansweredCount,
    super.timeTakenMinutes,
    super.answers,
  });

  factory ExamResultModel.fromJson(
    Map<String, dynamic> json, {
    required int attemptId,
  }) {
    final answers = (json['answers'] as List<dynamic>? ?? [])
        .map(
          (e) => ExamResultAnswerEntity(
            questionId: e['question_id'],
            selectedOptionId: e['selected_option_id'] ?? e['option_id'],
            correctOptionId: e['correct_option_id'],
            isCorrect: e['is_correct'] ?? false,
          ),
        )
        .toList();
    return ExamResultModel(
      attemptId: json['attempt_id'] ?? attemptId,
      score: toDouble(json['score']),
      totalMarks: toDoubleOrNull(json['total_marks']),
      percentage: toDouble(json['percentage']),
      isPassed: json['is_passed'] ?? false,
      correctAnswersCount: json['correct_answers'] ?? 0,
      wrongAnswersCount: json['wrong_answers'] ?? 0,
      unansweredCount: json['unanswered'] ?? 0,
      timeTakenMinutes: json['time_taken_minutes'],
      answers: answers,
    );
  }
}
