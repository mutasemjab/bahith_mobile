import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/exam_entity.dart';
import '../cubit/exam_cubit.dart';
import '../cubit/exam_state.dart';

/// Hosts both the live question-taking flow and the result screen once
/// submitted, sharing the single [ExamCubit] instance created by
/// [ExamDetailPage] so the countdown timer survives navigation.
class ExamTakePage extends StatelessWidget {
  final ExamCubit cubit;
  const ExamTakePage({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final state = cubit.state;
        if (state is ExamSubmitted || state is ExamError) {
          Navigator.of(context).pop();
          return;
        }
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('إنهاء الاختبار؟'),
            content: const Text('ستفقد إجاباتك الحالية إذا غادرت الآن.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('البقاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('مغادرة'),
              ),
            ],
          ),
        );
        if (confirmed == true && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        body: BlocBuilder<ExamCubit, ExamState>(
          bloc: cubit,
          builder: (context, state) {
            if (state is ExamSubmitting) return const LoadingWidget();
            if (state is ExamError) {
              return SafeArea(child: AppErrorView(message: state.message));
            }
            if (state is ExamSubmitted) {
              return _ExamResultView(state: state);
            }
            if (state is ExamStarted) {
              return _ExamQuestionsView(cubit: cubit, state: state);
            }
            return const LoadingWidget();
          },
        ),
      ),
    );
  }
}

class _ExamQuestionsView extends StatelessWidget {
  final ExamCubit cubit;
  final ExamStarted state;
  const _ExamQuestionsView({required this.cubit, required this.state});

  @override
  Widget build(BuildContext context) {
    final questions = state.exam.questions;
    final question = questions[state.currentQuestionIndex];
    final isLast = state.currentQuestionIndex == questions.length - 1;
    final selected = state.selectedAnswers[question.id];
    final lowTime = state.timeRemaining.inSeconds <= 60;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    state.exam.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (lowTime ? AppColors.accent : AppColors.primary)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 15,
                        color: lowTime ? AppColors.accent : AppColors.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        state.timeRemaining.clock,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: lowTime ? AppColors.accent : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: questions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final answered = state.selectedAnswers.containsKey(
                  questions[i].id,
                );
                final isCurrent = i == state.currentQuestionIndex;
                return GestureDetector(
                  onTap: () => cubit.goToQuestion(i),
                  child: Container(
                    width: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.primary
                          : answered
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: isCurrent
                            ? AppColors.primary
                            : answered
                            ? AppColors.success
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isCurrent
                            ? Colors.white
                            : answered
                            ? AppColors.success
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'السؤال ${state.currentQuestionIndex + 1} من ${questions.length}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.text,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      height: 1.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ...question.options.map((option) {
                    final isSelected = selected == option.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => cubit.selectAnswer(question.id, option.id),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : AppColors.card,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: isSelected ? 1.6 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  option.text,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                if (state.currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          cubit.goToQuestion(state.currentQuestionIndex - 1),
                      child: const Text('السابق'),
                    ),
                  ),
                if (state.currentQuestionIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLast
                        ? () => _confirmSubmit(context, cubit, state)
                        : () => cubit.goToQuestion(
                            state.currentQuestionIndex + 1,
                          ),
                    style: isLast
                        ? ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                          )
                        : null,
                    child: Text(isLast ? 'إنهاء وتسليم' : 'التالي'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSubmit(
    BuildContext context,
    ExamCubit cubit,
    ExamStarted state,
  ) async {
    final unanswered =
        state.exam.questions.length - state.selectedAnswers.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسليم الاختبار'),
        content: Text(
          unanswered > 0
              ? 'لديك $unanswered سؤال بدون إجابة. هل تريد التسليم الآن؟'
              : 'هل أنت متأكد من تسليم الاختبار؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تسليم'),
          ),
        ],
      ),
    );
    if (confirmed == true) cubit.submitExam();
  }
}

class _ExamResultView extends StatelessWidget {
  final ExamSubmitted state;
  const _ExamResultView({required this.state});

  @override
  Widget build(BuildContext context) {
    final result = state.result;
    final color = result.isPassed ? AppColors.success : AppColors.accent;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.1),
                border: Border.all(color: color, width: 4),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${result.percentage.toStringAsFixed(0)}٪',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                    Text(
                      result.isPassed ? 'ناجح' : 'راسب',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              result.isPassed ? 'أحسنت! لقد اجتزت الاختبار' : 'حاول مرة أخرى',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              result.totalMarks != null
                  ? '${state.exam.title} · ${result.score.toStringAsFixed(0)} من ${result.totalMarks!.toStringAsFixed(0)} علامة'
                  : '${state.exam.title} · ${result.score.toStringAsFixed(1)} نقطة',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _ResultStatTile(
                  icon: Icons.check_circle_rounded,
                  label: 'صحيحة',
                  value: '${result.correctAnswersCount}',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ResultStatTile(
                  icon: Icons.cancel_rounded,
                  label: 'خاطئة',
                  value: '${result.wrongAnswersCount}',
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ResultStatTile(
                  icon: Icons.help_outline_rounded,
                  label: 'بدون إجابة',
                  value: '${result.unansweredCount}',
                  color: AppColors.warning,
                ),
              ),
              if (result.timeTakenMinutes != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _ResultStatTile(
                    icon: Icons.timer_outlined,
                    label: 'الوقت (د)',
                    value: '${result.timeTakenMinutes}',
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
          if (result.answers.isNotEmpty) ...[
            const SizedBox(height: 28),
            const Text(
              'مراجعة الإجابات',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(state.exam.questions.length, (i) {
              final question = state.exam.questions[i];
              final answer = result.answers.firstWhere(
                (a) => a.questionId == question.id,
                orElse: () => const ExamResultAnswerEntity(
                  questionId: -1,
                  isCorrect: false,
                ),
              );
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: answer.isCorrect
                        ? AppColors.success
                        : AppColors.accent,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      answer.isCorrect
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: answer.isCorrect
                          ? AppColors.success
                          : AppColors.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${i + 1}. ${question.text}',
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/exams'),
            child: const Text('العودة إلى الاختبارات'),
          ),
        ],
      ),
    );
  }
}

class _ResultStatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ResultStatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
