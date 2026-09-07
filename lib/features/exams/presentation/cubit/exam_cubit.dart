import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/exam_repository.dart';
import 'exam_state.dart';

class ExamCubit extends Cubit<ExamState> {
  final ExamRepository _repository;
  Timer? _timer;

  ExamCubit(this._repository) : super(const ExamInitial());

  Future<void> loadExam(int examId) async {
    emit(const ExamLoading());
    final result = await _repository.getExam(examId);
    result.fold(
      (failure) => emit(ExamError(failure.message)),
      (exam) => emit(ExamLoaded(exam)),
    );
  }

  Future<void> startExam() async {
    final current = state;
    if (current is! ExamLoaded) return;

    emit(const ExamLoading());
    final result = await _repository.startExam(current.exam.id);
    result.fold((failure) => emit(ExamError(failure.message)), (attemptId) {
      final duration = Duration(minutes: current.exam.durationMinutes ?? 60);
      emit(
        ExamStarted(
          attemptId: attemptId,
          exam: current.exam,
          currentQuestionIndex: 0,
          selectedAnswers: const {},
          timeRemaining: duration,
        ),
      );
      _startTimer();
    });
  }

  void selectAnswer(int questionId, int optionId) {
    final current = state;
    if (current is! ExamStarted) return;
    emit(
      current.copyWith(
        selectedAnswers: {...current.selectedAnswers, questionId: optionId},
      ),
    );
  }

  void goToQuestion(int index) {
    final current = state;
    if (current is! ExamStarted) return;
    if (index < 0 || index >= current.exam.questions.length) return;
    emit(current.copyWith(currentQuestionIndex: index));
  }

  Future<void> submitExam() async {
    final current = state;
    if (current is! ExamStarted) return;

    _timer?.cancel();
    final exam = current.exam;
    emit(const ExamSubmitting());

    final result = await _repository.submitAttempt(
      attemptId: current.attemptId,
      answers: current.selectedAnswers,
    );

    result.fold(
      (failure) => emit(ExamError(failure.message)),
      (examResult) => emit(ExamSubmitted(examResult, exam)),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state;
      if (current is! ExamStarted) {
        _timer?.cancel();
        return;
      }
      final remaining = current.timeRemaining - const Duration(seconds: 1);
      if (remaining.inSeconds <= 0) {
        _timer?.cancel();
        submitExam();
      } else {
        emit(current.copyWith(timeRemaining: remaining));
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
