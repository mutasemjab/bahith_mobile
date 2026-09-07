import 'package:equatable/equatable.dart';

class ExamOptionEntity extends Equatable {
  final int id;
  final String text;
  final bool? isCorrect;

  const ExamOptionEntity({
    required this.id,
    required this.text,
    this.isCorrect,
  });

  @override
  List<Object?> get props => [id, text, isCorrect];
}

class ExamQuestionEntity extends Equatable {
  final int id;
  final String text;
  final String? image;
  final List<ExamOptionEntity> options;

  const ExamQuestionEntity({
    required this.id,
    required this.text,
    this.image,
    this.options = const [],
  });

  @override
  List<Object?> get props => [id, text, options];
}

class ExamEntity extends Equatable {
  final int id;
  final String title;
  final String? description;
  final String? subjectName;
  final String? examType;
  final int? durationMinutes;
  final int questionsCount;
  final double? passingScore;
  final bool showResultImmediately;
  final List<ExamQuestionEntity> questions;

  const ExamEntity({
    required this.id,
    required this.title,
    this.description,
    this.subjectName,
    this.examType,
    this.durationMinutes,
    this.questionsCount = 0,
    this.passingScore,
    this.showResultImmediately = true,
    this.questions = const [],
  });

  @override
  List<Object?> get props => [id, title, questions];
}

class ExamResultAnswerEntity extends Equatable {
  final int questionId;
  final int? selectedOptionId;
  final int? correctOptionId;
  final bool isCorrect;

  const ExamResultAnswerEntity({
    required this.questionId,
    this.selectedOptionId,
    this.correctOptionId,
    required this.isCorrect,
  });

  @override
  List<Object?> get props => [
    questionId,
    selectedOptionId,
    correctOptionId,
    isCorrect,
  ];
}

class ExamResultEntity extends Equatable {
  final int attemptId;
  final double score;
  final double? totalMarks;
  final double percentage;
  final bool isPassed;
  final int correctAnswersCount;
  final int wrongAnswersCount;
  final int unansweredCount;
  final int? timeTakenMinutes;
  final List<ExamResultAnswerEntity> answers;

  const ExamResultEntity({
    required this.attemptId,
    required this.score,
    this.totalMarks,
    required this.percentage,
    required this.isPassed,
    this.correctAnswersCount = 0,
    this.wrongAnswersCount = 0,
    this.unansweredCount = 0,
    this.timeTakenMinutes,
    this.answers = const [],
  });

  @override
  List<Object?> get props => [attemptId, score, percentage, isPassed];
}
