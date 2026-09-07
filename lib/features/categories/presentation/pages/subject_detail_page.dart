import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../courses/presentation/widgets/course_card.dart';
import '../../domain/entities/category_detail_entity.dart';
import '../cubit/category_cubit.dart';

class SubjectDetailPage extends StatelessWidget {
  final int subjectId;
  const SubjectDetailPage({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SubjectDetailCubit>()..load(subjectId),
      child: Scaffold(
        appBar: AppBar(title: const Text('دورات المادة')),
        body:
            BlocBuilder<SubjectDetailCubit, ResourceState<SubjectDetailEntity>>(
              builder: (context, state) {
                if (state is ResourceLoading) return const LoadingWidget();
                if (state is ResourceError<SubjectDetailEntity>) {
                  return AppErrorView(
                    message: state.message,
                    onRetry: () =>
                        context.read<SubjectDetailCubit>().load(subjectId),
                  );
                }
                final detail =
                    (state as ResourceLoaded<SubjectDetailEntity>).data;
                if (detail.courses.isEmpty) {
                  return const EmptyState(
                    message: 'لا توجد دورات لهذه المادة حالياً',
                    icon: Icons.menu_book_rounded,
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () =>
                      context.read<SubjectDetailCubit>().load(subjectId),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
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
                );
              },
            ),
      ),
    );
  }
}
