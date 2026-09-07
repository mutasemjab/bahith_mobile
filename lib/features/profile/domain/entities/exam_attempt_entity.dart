import 'package:equatable/equatable.dart';

class ExamAttemptEntity extends Equatable {
  final int id;
  final String examTitle;
  final double score;
  final double percentage;
  final bool isPassed;
  final String? submittedAt;

  const ExamAttemptEntity({
    required this.id,
    required this.examTitle,
    required this.score,
    required this.percentage,
    required this.isPassed,
    this.submittedAt,
  });

  @override
  List<Object?> get props => [id, examTitle, score, percentage, isPassed];
}
