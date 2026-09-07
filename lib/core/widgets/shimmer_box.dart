import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.radius = AppRadius.sm,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Skeleton for a horizontal card list (courses, teachers, etc.)
class ShimmerCardList extends StatelessWidget {
  final int count;
  final double itemWidth;
  final double itemHeight;
  final Axis direction;

  const ShimmerCardList({
    super.key,
    this.count = 4,
    this.itemWidth = 170,
    this.itemHeight = 210,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    if (direction == Axis.horizontal) {
      return SizedBox(
        height: itemHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: count,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, _) => ShimmerBox(
            width: itemWidth,
            height: itemHeight,
            radius: AppRadius.md,
          ),
        ),
      );
    }
    return Column(
      children: List.generate(
        count,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShimmerBox(height: itemHeight, radius: AppRadius.md),
        ),
      ),
    );
  }
}

/// Skeleton for a full-bleed list screen (page bodies).
class ShimmerListScreen extends StatelessWidget {
  final int count;
  const ShimmerListScreen({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) =>
          const ShimmerBox(height: 110, radius: AppRadius.md),
    );
  }
}
