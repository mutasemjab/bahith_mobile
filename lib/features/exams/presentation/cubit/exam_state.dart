import 'package:equatable/equatable.dart';

import '../../domain/entities/exam_entity.dart';

abstract class ExamState extends Equatable {
  const ExamState();
  @override
  List<Object?> get props => [];
}

class ExamInitial extends ExamState {
  const ExamInitial();
}

class ExamLoading extends ExamState {
  const ExamLoading();
}

class ExamLoaded extends ExamState {
  final ExamEntity exam;
  const ExamLoaded(this.exam);
  @override
  List<Object?> get props => [exam];
}

class ExamStarted extends ExamState {
  final int attemptId;
  final ExamEntity exam;
  final int currentQuestionIndex;
  final Map<int, int> selectedAnswers;
  final Duration timeRemaining;

  const ExamStarted({
    required this.attemptId,
    required this.exam,
    required this.currentQuestionIndex,
    required this.selectedAnswers,
    required this.timeRemaining,
  });

  @override
  List<Object?> get props => [
    attemptId,
    currentQuestionIndex,
    selectedAnswers,
    timeRemaining,
  ];

  ExamStarted copyWith({
    int? currentQuestionIndex,
    Map<int, int>? selectedAnswers,
    Duration? timeRemaining,
  }) => ExamStarted(
    attemptId: attemptId,
    exam: exam,
    currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
    selectedAnswers: selectedAnswers ?? this.selectedAnswers,
    timeRemaining: timeRemaining ?? this.timeRemaining,
  );
}

class ExamSubmitting extends ExamState {
  const ExamSubmitting();
}

class ExamSubmitted extends ExamState {
  final ExamResultEntity result;
  final ExamEntity exam;
  const ExamSubmitted(this.result, this.exam);
  @override
  List<Object?> get props => [result, exam];
}

class ExamError extends ExamState {
  final String message;
  const ExamError(this.message);
  @override
  List<Object?> get props => [message];
}
