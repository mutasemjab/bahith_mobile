import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../courses/presentation/widgets/course_card.dart';
import '../../domain/entities/teacher_detail_entity.dart';
import '../cubit/teacher_detail_cubit.dart';

class TeacherDetailPage extends StatelessWidget {
  final int teacherId;
  const TeacherDetailPage({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TeacherDetailCubit>()..load(teacherId),
      child: Scaffold(
        appBar: AppBar(title: const Text('الملف الشخصي')),
        body:
            BlocBuilder<TeacherDetailCubit, ResourceState<TeacherDetailEntity>>(
              builder: (context, state) {
                if (state is ResourceLoading) return const LoadingWidget();
                if (state is ResourceError<TeacherDetailEntity>) {
                  return AppErrorView(
                    message: state.message,
                    onRetry: () =>
                        context.read<TeacherDetailCubit>().load(teacherId),
                  );
                }
                final detail =
                    (state as ResourceLoaded<TeacherDetailEntity>).data;
                final teacher = detail.teacher;
                return ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: AppNetworkImage(
                              url: teacher.avatar,
                              width: 96,
                              height: 96,
                              radius: 999,
                              fallbackIcon: Icons.person_rounded,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            teacher.name,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (teacher.specialization != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              teacher.specialization!,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _StatChip(
                                icon: Icons.star_rounded,
                                label: teacher.rating.toStringAsFixed(1),
                                color: AppColors.gold,
                              ),
                              const SizedBox(width: 10),
                              _StatChip(
                                icon: Icons.menu_book_rounded,
                                label: '${teacher.coursesCount.arDigits} دورة',
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                          if (teacher.bio != null &&
                              teacher.bio!.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            Text(
                              teacher.bio!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.textMuted,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SectionHeader(title: 'دورات المعلم'),
                    const SizedBox(height: 12),
                    if (detail.courses.isEmpty)
                      const EmptyState(message: 'لا توجد دورات لهذا المعلم بعد')
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                childAspectRatio: 0.72,
                              ),
                          itemCount: detail.courses.length,
                          itemBuilder: (_, i) => CourseCard(
                            course: detail.courses[i],
                            width: double.infinity,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
