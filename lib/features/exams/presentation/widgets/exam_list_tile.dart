import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/exam_entity.dart';

class ExamListTile extends StatelessWidget {
  final ExamEntity exam;
  const ExamListTile({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => context.push('/exams/${exam.id}'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.quiz_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (exam.examType != null) ...[
                          StatusBadge(
                            label: exam.examType!,
                            color: AppColors.primary,
                            icon: Icons.label_rounded,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Icon(
                          Icons.help_outline_rounded,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${exam.questionsCount} سؤال',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                        if (exam.durationMinutes != null) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.timer_outlined,
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${exam.durationMinutes} د',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 14,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
