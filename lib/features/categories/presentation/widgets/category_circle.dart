import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/bootstrap_icons.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/category_entity.dart';

class CategoryCircle extends StatelessWidget {
  final CategoryEntity category;
  final int index;

  const CategoryCircle({super.key, required this.category, this.index = 0});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.gradientForIndex(index);
    return GestureDetector(
      onTap: () => context.push('/categories/${category.id}'),
      child: SizedBox(
        width: 82,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(20),
              ),
              child: category.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AppNetworkImage(
                        url: category.image,
                        width: 64,
                        height: 64,
                        radius: 20,
                      ),
                    )
                  : Icon(
                      bootstrapIconFor(category.icon) ?? Icons.category_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
