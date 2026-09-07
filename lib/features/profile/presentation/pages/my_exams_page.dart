import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/exam_attempt_entity.dart';
import '../cubit/my_exams_cubit.dart';

class MyExamsPage extends StatefulWidget {
  const MyExamsPage({super.key});

  @override
  State<MyExamsPage> createState() => _MyExamsPageState();
}

class _MyExamsPageState extends State<MyExamsPage> {
  late final MyExamsCubit _cubit = sl<MyExamsCubit>()..loadFirstPage();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختباراتي')),
      body: PaginatedListView<ExamAttemptEntity>(
        cubit: _cubit,
        emptyMessage: 'لم تخض أي اختبار بعد',
        emptyIcon: Icons.assignment_turned_in_rounded,
        itemBuilder: (_, attempt) => _AttemptTile(attempt: attempt),
      ),
    );
  }
}

class _AttemptTile extends StatelessWidget {
  final ExamAttemptEntity attempt;
  const _AttemptTile({required this.attempt});

  @override
  Widget build(BuildContext context) {
    final color = attempt.isPassed ? AppColors.success : AppColors.accent;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${attempt.percentage.toStringAsFixed(0)}٪',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attempt.examTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                StatusBadge(
                  label: attempt.isPassed ? 'ناجح' : 'راسب',
                  color: color,
                  icon: attempt.isPassed
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
