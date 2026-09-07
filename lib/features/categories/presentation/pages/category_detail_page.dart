import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/category_detail_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../cubit/category_cubit.dart';

class CategoryDetailPage extends StatelessWidget {
  final int categoryId;
  const CategoryDetailPage({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoryDetailCubit>()..load(categoryId),
      child: Scaffold(
        appBar: AppBar(title: const Text('تفاصيل القسم')),
        body:
            BlocBuilder<
              CategoryDetailCubit,
              ResourceState<CategoryDetailEntity>
            >(
              builder: (context, state) {
                if (state is ResourceLoading) return const LoadingWidget();
                if (state is ResourceError<CategoryDetailEntity>) {
                  return AppErrorView(
                    message: state.message,
                    onRetry: () =>
                        context.read<CategoryDetailCubit>().load(categoryId),
                  );
                }
                final detail =
                    (state as ResourceLoaded<CategoryDetailEntity>).data;
                return ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: AppNetworkImage(
                              url: detail.category.image,
                              width: 64,
                              height: 64,
                              fallbackIcon: Icons.category_rounded,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  detail.category.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${detail.subjects.length} مادة',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (detail.children.isNotEmpty) ...[
                      const SectionHeader(title: 'أقسام فرعية'),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: detail.children
                              .map(
                                (child) => ActionChip(
                                  label: Text(child.name),
                                  onPressed: () =>
                                      context.push('/categories/${child.id}'),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 22),
                    ],
                    if (detail.subjects.isNotEmpty) ...[
                      const SectionHeader(title: 'المواد الدراسية'),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: detail.subjects
                              .map(
                                (subject) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _SubjectTile(subject: subject),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  final SubjectEntity subject;
  const _SubjectTile({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: () => context.push('/subjects/${subject.id}'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  subject.name,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
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
