import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/app_settings_service.dart';
import '../../../../core/services/apple_iap_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../courses/presentation/widgets/activate_course_sheet.dart';
import '../../../courses/presentation/widgets/apple_course_purchase_sheet.dart';
import '../../domain/entities/course_content_entity.dart';
import '../cubit/course_content_cubit.dart';
import '../cubit/course_progress_cubit.dart';

class CourseContentPage extends StatefulWidget {
  final int courseId;
  const CourseContentPage({super.key, required this.courseId});

  @override
  State<CourseContentPage> createState() => _CourseContentPageState();
}

class _CourseContentPageState extends State<CourseContentPage> {
  late final CourseContentCubit _cubit = sl<CourseContentCubit>()
    ..load(widget.courseId);
  late final CourseProgressCubit _progressCubit = sl<CourseProgressCubit>()
    ..load(widget.courseId);

  @override
  void dispose() {
    _cubit.close();
    _progressCubit.close();
    super.dispose();
  }

  Future<void> _onActivated() async {
    await _cubit.load(widget.courseId);
    // The re-fetched content may still not report is_enrolled correctly
    // (same API unreliability as the course detail page) — force it
    // locally now that activation is confirmed.
    _cubit.markEnrolled();
    _progressCubit.load(widget.courseId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تفعيل الدورة بنجاح 🎉'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _openLesson(
    BuildContext context,
    ContentLessonEntity lesson,
  ) async {
    final progressState = _progressCubit.state;
    final progress = progressState is ResourceLoaded<CourseProgressEntity>
        ? progressState.data
        : null;
    final resumeSeconds = progress?.resumeSecondsFor(lesson.id);
    await context.push(
      resumeSeconds != null
          ? '/lessons/${lesson.id}?resume=$resumeSeconds'
          : '/lessons/${lesson.id}',
    );
    // The lesson may have just been marked completed / its position saved —
    // refresh so the checkmarks and percentage reflect that immediately.
    if (mounted) _progressCubit.load(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('محتوى الدورة')),
      body: BlocBuilder<CourseContentCubit, ResourceState<CourseContentEntity>>(
        bloc: _cubit,
        builder: (context, state) {
          if (state is ResourceLoading) return const LoadingWidget();
          if (state is ResourceError<CourseContentEntity>) {
            return AppErrorView(
              message: state.message,
              onRetry: () => _cubit.load(widget.courseId),
            );
          }
          final content = (state as ResourceLoaded<CourseContentEntity>).data;
          final showCommerce = AppSettingsScope.of(context).showCommerce;
          if (content.units.isEmpty) {
            return const EmptyState(
              message: 'لا يوجد محتوى منشور لهذه الدورة بعد',
              icon: Icons.menu_book_rounded,
            );
          }
          return Column(
            children: [
              if (showCommerce && !content.isEnrolled)
                _ActivationBanner(
                  courseId: widget.courseId,
                  onActivated: _onActivated,
                ),
              if (content.isEnrolled)
                BlocBuilder<
                  CourseProgressCubit,
                  ResourceState<CourseProgressEntity>
                >(
                  bloc: _progressCubit,
                  builder: (context, progressState) {
                    if (progressState
                        is! ResourceLoaded<CourseProgressEntity>) {
                      return const SizedBox.shrink();
                    }
                    return _ProgressHeader(progress: progressState.data);
                  },
                ),
              Expanded(
                child:
                    BlocBuilder<
                      CourseProgressCubit,
                      ResourceState<CourseProgressEntity>
                    >(
                      bloc: _progressCubit,
                      builder: (context, progressState) {
                        final progress =
                            progressState
                                is ResourceLoaded<CourseProgressEntity>
                            ? progressState.data
                            : null;
                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: content.units.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) => _UnitCard(
                            unit: content.units[i],
                            courseId: widget.courseId,
                            progress: progress,
                            onActivated: _onActivated,
                            onOpenLesson: _openLesson,
                          ),
                        );
                      },
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Course-wide completion summary shown above the unit list once enrolled.
class _ProgressHeader extends StatelessWidget {
  final CourseProgressEntity progress;
  const _ProgressHeader({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'تقدمك في الدورة',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                '${progress.percentage}٪',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (progress.percentage / 100).clamp(0, 1),
              minHeight: 7,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation(AppColors.success),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.play_circle_outline_rounded,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                '${progress.completedLessons} / ${progress.totalLessons} درس',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                ),
              ),
              if (progress.totalExams > 0) ...[
                const SizedBox(width: 14),
                const Icon(
                  Icons.quiz_rounded,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '${progress.completedExams} / ${progress.totalExams} امتحان',
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
    );
  }
}

/// Persistent prompt shown above the unit list whenever the student isn't
/// enrolled yet, so activation doesn't require first hunting down a
/// locked lesson to tap.
class _ActivationBanner extends StatelessWidget {
  final int courseId;
  final VoidCallback onActivated;
  const _ActivationBanner({required this.courseId, required this.onActivated});

  @override
  Widget build(BuildContext context) {
    if (!AppSettingsScope.of(context).showCommerce) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded, color: Colors.white),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'أنت غير مشترك بهذه الدورة بعد',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (AppleIapService.isSupportedPlatform) {
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
            child: Text(
              AppleIapService.isSupportedPlatform
                  ? 'شراء عبر App Store'
                  : 'تفعيل بالبطاقة',
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final ContentUnitEntity unit;
  final int courseId;
  final CourseProgressEntity? progress;
  final VoidCallback onActivated;
  final void Function(BuildContext, ContentLessonEntity) onOpenLesson;
  const _UnitCard({
    required this.unit,
    required this.courseId,
    required this.progress,
    required this.onActivated,
    required this.onOpenLesson,
  });

  void _openLesson(BuildContext context, ContentLessonEntity lesson) {
    if (lesson.isLocked) {
      final showCommerce = AppSettingsScope.of(context).showCommerce;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(showCommerce ? 'محتوى مقفل' : 'محتوى غير متاح'),
          content: Text(
            !showCommerce
                ? 'هذا الدرس غير متاح لحسابك حالياً.'
                : 'هذا الدرس يتطلب تفعيل الدورة للوصول إليه.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(showCommerce ? 'إلغاء' : 'حسناً'),
            ),
            if (showCommerce)
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (AppleIapService.isSupportedPlatform) {
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
                child: Text(
                  AppleIapService.isSupportedPlatform
                      ? 'شراء الآن'
                      : 'تفعيل الآن',
                ),
              ),
          ],
        ),
      );
      return;
    }
    onOpenLesson(context, lesson);
  }

  void _openUnitExams(BuildContext context) {
    if (unit.exams.length == 1) {
      context.push('/exams/${unit.exams.first.id}');
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: unit.exams
              .map(
                (exam) => ListTile(
                  leading: const Icon(
                    Icons.quiz_rounded,
                    color: AppColors.primary,
                  ),
                  title: Text(exam.title),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/exams/${exam.id}');
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showCommerce = AppSettingsScope.of(context).showCommerce;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          title: Text(
            unit.title,
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            '${unit.lessons.length} درس',
            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
          ),
          children: [
            ...unit.lessons.map((lesson) {
              final isCompleted =
                  progress?.isLessonCompleted(lesson.id) ?? false;
              final resumeSeconds = progress?.resumeSecondsFor(lesson.id);
              return ListTile(
                onTap: () => _openLesson(context, lesson),
                leading: Icon(
                  lesson.isLocked
                      ? Icons.lock_rounded
                      : isCompleted
                      ? Icons.check_circle_rounded
                      : lesson.lessonType == 'pdf'
                      ? Icons.picture_as_pdf_rounded
                      : Icons.play_circle_outline_rounded,
                  color: lesson.isLocked
                      ? AppColors.textMuted
                      : isCompleted
                      ? AppColors.success
                      : AppColors.primary,
                ),
                title: Text(
                  lesson.title,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: lesson.isLocked
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                  ),
                ),
                subtitle:
                    !lesson.isLocked && !isCompleted && resumeSeconds != null
                    ? Text(
                        'آخر مشاهدة: ${_formatSeconds(resumeSeconds)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      )
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showCommerce && lesson.isFree) ...[
                      const StatusBadge(
                        label: 'مجاني',
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (lesson.durationMinutes != null)
                      Text(
                        '${lesson.durationMinutes} د',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              );
            }),
            if (unit.exams.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                child: OutlinedButton.icon(
                  onPressed: () => _openUnitExams(context),
                  icon: const Icon(Icons.quiz_rounded, size: 18),
                  label: Text(
                    unit.exams.length == 1
                        ? 'امتحان الوحدة'
                        : 'امتحانات الوحدة',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _formatSeconds(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
