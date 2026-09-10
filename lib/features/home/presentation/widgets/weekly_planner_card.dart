import 'package:flutter/material.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../../weekly_planner/domain/entities/weekly_planner_entity.dart';

/// A single home card for the latest weekly planner — hidden entirely
/// while loading, on error, or when none matches the student's class and
/// current date window (all normal, non-error outcomes here).
class WeeklyPlannerCard extends StatelessWidget {
  final ResourceState<WeeklyPlannerEntity?> state;

  const WeeklyPlannerCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is! ResourceLoaded<WeeklyPlannerEntity?>) {
      return const SizedBox.shrink();
    }
    final planner = (state as ResourceLoaded<WeeklyPlannerEntity?>).data;
    if (planner == null) return const SizedBox.shrink();

    final dateRange = _dateRangeLabel(planner);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => showFullscreenImage(context, planner.imageUrl),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.event_note_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planner.title.isEmpty
                            ? 'المفكرة الأسبوعية'
                            : planner.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (dateRange != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          dateRange,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
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
      ),
    );
  }

  String? _dateRangeLabel(WeeklyPlannerEntity planner) {
    final start = planner.startDate;
    final end = planner.endDate;
    if (start == null && end == null) return null;
    if (start != null && end != null) return '${start.arDate} - ${end.arDate}';
    return (start ?? end)!.arDate;
  }
}
