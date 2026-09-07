import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/app_settings_service.dart';
import '../../../../core/services/apple_iap_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/course_entity.dart';
import '../cubit/course_detail_cubit.dart';
import '../widgets/activate_course_sheet.dart';
import '../widgets/apple_course_purchase_sheet.dart';

class CourseDetailPage extends StatelessWidget {
  final int courseId;
  const CourseDetailPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CourseDetailCubit>()..load(courseId),
      child: Scaffold(
        body: BlocBuilder<CourseDetailCubit, ResourceState<CourseEntity>>(
          builder: (context, state) {
            if (state is ResourceLoading) {
              return const Scaffold(body: LoadingWidget());
            }
            if (state is ResourceError<CourseEntity>) {
              return Scaffold(
                appBar: AppBar(),
                body: AppErrorView(
                  message: state.message,
                  onRetry: () =>
                      context.read<CourseDetailCubit>().load(courseId),
                ),
              );
            }
            final course = (state as ResourceLoaded<CourseEntity>).data;
            final showCommerce = AppSettingsScope.of(context).showCommerce;
            final usesAppleIap = AppleIapService.isSupportedPlatform;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 220,
                  backgroundColor: AppColors.surface,
                  flexibleSpace: FlexibleSpaceBar(
                    background: AppNetworkImage(
                      url: course.image,
                      height: 220,
                      radius: 0,
                      fallbackIcon: Icons.menu_book_rounded,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.gold,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              course.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Icon(
                              Icons.groups_rounded,
                              size: 16,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${course.studentsCount.arDigits} طالب',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Icon(
                              course.lessonsCount > 0
                                  ? Icons.play_circle_outline_rounded
                                  : Icons.schedule_rounded,
                              size: 16,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              course.lessonsCount > 0
                                  ? '${course.lessonsCount.arDigits} درس'
                                  : course.durationHours != null
                                  ? '${course.durationHours!.toStringAsFixed(0)} ساعة'
                                  : '-',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12.5,
                              ),
                            ),
                            if (course.difficultyLevel != null) ...[
                              const SizedBox(width: 14),
                              StatusBadge(
                                label: _difficultyLabel(
                                  course.difficultyLevel!,
                                ),
                                color: AppColors.warning,
                              ),
                            ],
                          ],
                        ),
                        if (showCommerce &&
                            (!usesAppleIap || course.isFree) &&
                            (!course.isFree || course.price != null)) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  course.isFree
                                      ? Icons.card_giftcard_rounded
                                      : Icons.sell_rounded,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  course.isFree
                                      ? 'دورة مجانية'
                                      : '${course.price?.toStringAsFixed(0) ?? '-'} د.أ',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                if (!course.isFree &&
                                    course.oldPrice != null &&
                                    course.oldPrice! > (course.price ?? 0)) ...[
                                  const SizedBox(width: 10),
                                  Text(
                                    course.oldPrice!.toStringAsFixed(0),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withValues(
                                        alpha: 0.75,
                                      ),
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                if (course.discountPercent != null &&
                                    course.discountPercent! > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.18,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'خصم ${course.discountPercent}٪',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        if (course.teacherName != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: AppNetworkImage(
                                    url: course.teacherAvatar,
                                    width: 42,
                                    height: 42,
                                    radius: 999,
                                    fallbackIcon: Icons.person_rounded,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'المعلم',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      Text(
                                        course.teacherName!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (course.teacherId != null)
                                  TextButton(
                                    onPressed: () => context.push(
                                      '/teachers/${course.teacherId}',
                                    ),
                                    child: const Text('الملف الشخصي'),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        if (course.progress != null) ...[
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: course.progress!.clamp(0, 1),
                              minHeight: 8,
                              backgroundColor: AppColors.divider,
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.success,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'اكتمل ${(course.progress! * 100).toStringAsFixed(0)}٪',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                        if (course.description != null &&
                            course.description!.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'عن الدورة',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            course.description!,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: AppColors.textMuted,
                              height: 1.6,
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        OutlinedButton.icon(
                          onPressed: () =>
                              context.push('/courses/$courseId/content'),
                          icon: const Icon(Icons.menu_book_rounded),
                          label: const Text('محتوى الدورة'),
                        ),
                        if (showCommerce &&
                            !course.isEnrolled &&
                            (!usesAppleIap || !course.isFree)) ...[
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              void onActivated() async {
                                final cubit = context.read<CourseDetailCubit>();
                                await cubit.load(courseId);
                                // The re-fetched course may still not report
                                // is_enrolled correctly (the API has been
                                // unreliable about this field) — force it
                                // locally now that activation is confirmed.
                                cubit.markEnrolled();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم تفعيل الدورة بنجاح 🎉'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }

                              if (usesAppleIap) {
                                showAppleCoursePurchaseSheet(
                                  context: context,
                                  courseId: courseId,
                                  onPurchased: onActivated,
                                );
                              } else {
                                showActivateCourseSheet(
                                  context: context,
                                  courseId: courseId,
                                  onActivated: onActivated,
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.shopping_cart_checkout_rounded,
                            ),
                            label: Text(
                              usesAppleIap
                                  ? 'شراء الدورة من App Store'
                                  : 'الاشتراك في الدورة',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        ),
      ),
    );
  }
}

String _difficultyLabel(String level) {
  switch (level) {
    case 'beginner':
      return 'مبتدئ';
    case 'intermediate':
      return 'متوسط';
    case 'advanced':
      return 'متقدم';
    default:
      return level;
  }
}
