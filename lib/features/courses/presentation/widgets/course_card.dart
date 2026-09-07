import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/app_settings_service.dart';
import '../../../../core/services/apple_iap_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/course_entity.dart';

/// Compact vertical course card used across home, courses list & my-courses.
class CourseCard extends StatelessWidget {
  final CourseEntity course;
  final double width;

  const CourseCard({super.key, required this.course, this.width = 174});

  @override
  Widget build(BuildContext context) {
    final showCommerce = AppSettingsScope.of(context).showCommerce;
    final hasDiscount =
        showCommerce &&
        !AppleIapService.isSupportedPlatform &&
        course.discountPercent != null &&
        course.discountPercent! > 0;

    return GestureDetector(
      onTap: () => context.push('/courses/${course.id}'),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.md),
                  ),
                  child: AppNetworkImage(
                    url: course.image,
                    width: width,
                    height: 100,
                    radius: 0,
                    fallbackIcon: Icons.menu_book_rounded,
                  ),
                ),
                if (course.featured || course.trending)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: course.trending
                            ? AppColors.accentGradient
                            : AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        course.trending ? 'الأكثر رواجاً' : 'مميز',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'خصم ${course.discountPercent}٪',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (course.progress != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ClipRRect(
                      child: LinearProgressIndicator(
                        value: course.progress!.clamp(0, 1),
                        minHeight: 4,
                        backgroundColor: Colors.white.withValues(alpha: 0.5),
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.success,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (course.teacherName != null)
                    Text(
                      course.teacherName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        course.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (course.durationHours != null) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${course.durationHours!.toStringAsFixed(0)} س',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (course.isEnrolled && course.progress != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: course.progress!.clamp(0, 1),
                              minHeight: 6,
                              backgroundColor: AppColors.divider,
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.success,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${(course.progress! * 100).toStringAsFixed(0)}٪',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
