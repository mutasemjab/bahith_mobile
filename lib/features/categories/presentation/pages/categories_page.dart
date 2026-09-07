import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/bootstrap_icons.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../domain/entities/category_entity.dart';
import '../cubit/category_cubit.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoriesCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('الأقسام')),
        body: BlocBuilder<CategoriesCubit, ResourceState<List<CategoryEntity>>>(
          builder: (context, state) {
            if (state is ResourceLoading) {
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.3,
                ),
                itemCount: 6,
                itemBuilder: (_, _) =>
                    const ShimmerBox(height: 110, radius: AppRadius.md),
              );
            }
            if (state is ResourceError<List<CategoryEntity>>) {
              return AppErrorView(
                message: state.message,
                onRetry: () => context.read<CategoriesCubit>().load(),
              );
            }
            final categories =
                (state as ResourceLoaded<List<CategoryEntity>>).data;
            if (categories.isEmpty) {
              return const EmptyState(message: 'لا توجد أقسام متاحة حالياً');
            }
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<CategoriesCubit>().load(),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.3,
                ),
                itemCount: categories.length,
                itemBuilder: (_, i) =>
                    _CategoryTile(category: categories[i], index: i),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryEntity category;
  final int index;
  const _CategoryTile({required this.category, required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.gradientForIndex(index);
    return GestureDetector(
      onTap: () => context.push('/categories/${category.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors[0].withValues(alpha: 0.10),
              colors[1].withValues(alpha: 0.04),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(14),
              ),
              child: category.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: AppNetworkImage(
                        url: category.image,
                        width: 46,
                        height: 46,
                        radius: 14,
                      ),
                    )
                  : Icon(
                      bootstrapIconFor(category.icon) ?? Icons.category_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
            ),
            const Spacer(),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${category.subcategoriesCount} قسم فرعي',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
