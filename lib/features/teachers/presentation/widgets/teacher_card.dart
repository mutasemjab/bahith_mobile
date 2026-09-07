import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/teacher_entity.dart';

class TeacherCard extends StatelessWidget {
  final TeacherEntity teacher;
  final double width;

  const TeacherCard({super.key, required this.teacher, this.width = 140});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/teachers/${teacher.id}'),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: AppNetworkImage(
                url: teacher.avatar,
                width: 64,
                height: 64,
                radius: 999,
                fallbackIcon: Icons.person_rounded,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              teacher.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            if (teacher.specialization != null) ...[
              const SizedBox(height: 3),
              Text(
                teacher.specialization!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, size: 13, color: AppColors.gold),
                const SizedBox(width: 2),
                Text(
                  teacher.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '· ${teacher.coursesCount} دورة',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
