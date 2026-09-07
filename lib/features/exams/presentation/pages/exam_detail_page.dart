import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../cubit/exam_cubit.dart';
import '../cubit/exam_state.dart';

class ExamDetailPage extends StatefulWidget {
  final int examId;
  const ExamDetailPage({super.key, required this.examId});

  @override
  State<ExamDetailPage> createState() => _ExamDetailPageState();
}

class _ExamDetailPageState extends State<ExamDetailPage> {
  late final ExamCubit _cubit = sl<ExamCubit>()..loadExam(widget.examId);

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _startExam() async {
    await _cubit.startExam();
    if (!mounted) return;
    if (_cubit.state is ExamStarted) {
      context.push('/exams/${widget.examId}/take', extra: _cubit);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الاختبار')),
      body: BlocBuilder<ExamCubit, ExamState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state is ExamInitial || state is ExamLoading) {
            return const LoadingWidget();
          }
          if (state is ExamError) {
            return AppErrorView(
              message: state.message,
              onRetry: () => _cubit.loadExam(widget.examId),
            );
          }

          final exam = state is ExamLoaded
              ? state.exam
              : state is ExamStarted
              ? state.exam
              : null;
          if (exam == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.quiz_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        exam.title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      if (exam.subjectName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          exam.subjectName!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.help_outline_rounded,
                        label: 'الأسئلة',
                        value: '${exam.questionsCount}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.timer_outlined,
                        label: 'المدة',
                        value: exam.durationMinutes != null
                            ? '${exam.durationMinutes} د'
                            : '-',
                      ),
                    ),
                  ],
                ),
                if (exam.description != null &&
                    exam.description!.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const Text(
                    'تعليمات الاختبار',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exam.description!,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textMuted,
                      height: 1.6,
                    ),
                  ),
                ],
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _startExam,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('ابدأ الاختبار'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
