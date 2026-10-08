import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../domain/entities/weekly_planner_entity.dart';

/// Full view of a weekly planner — Arabic title+image, then English
/// title+image, stacked top to bottom. Each image still opens the
/// fullscreen pinch-zoom viewer on tap.
class WeeklyPlannerPage extends StatelessWidget {
  final WeeklyPlannerEntity planner;
  const WeeklyPlannerPage({super.key, required this.planner});

  @override
  Widget build(BuildContext context) {
    final dateRange = _dateRangeLabel();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          planner.title.isEmpty ? 'المفكرة الأسبوعية' : planner.title,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (dateRange != null) ...[
            Text(
              dateRange,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
          ],
          _PlannerSection(label: 'عربي', url: planner.imageArUrl),
          const SizedBox(height: 24),
          _PlannerSection(label: 'English', url: planner.imageEnUrl),
        ],
      ),
    );
  }

  String? _dateRangeLabel() {
    final start = planner.startDate;
    final end = planner.endDate;
    if (start == null && end == null) return null;
    if (start != null && end != null) return '${start.arDate} - ${end.arDate}';
    return (start ?? end)!.arDate;
  }
}

class _PlannerSection extends StatelessWidget {
  final String label;
  final String url;
  const _PlannerSection({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => showFullscreenImage(context, url),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: AppNetworkImage(
              url: url,
              height: 260,
              width: double.infinity,
              radius: AppRadius.md,
              fallbackIcon: Icons.image_rounded,
            ),
          ),
        ),
      ],
    );
  }
}
