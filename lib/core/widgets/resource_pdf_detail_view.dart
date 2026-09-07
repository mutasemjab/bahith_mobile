import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import 'pdf_viewer_page.dart';
import 'status_badge.dart';

/// Shared detail layout for PDF-backed resources — previous-year exams,
/// question banks and worksheets all render the same info-card + "view
/// file" pattern, so the per-feature detail pages just supply the content.
class ResourcePdfDetailView extends StatelessWidget {
  final String title;
  final List<String> badges;
  final String? description;
  final String? fileUrl;

  const ResourcePdfDetailView({
    super.key,
    required this.title,
    this.badges = const [],
    this.description,
    this.fileUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: AppColors.accent,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (badges.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: badges
                        .map(
                          (b) =>
                              StatusBadge(label: b, color: AppColors.primary),
                        )
                        .toList(),
                  ),
                ],
                if (description != null && description!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    description!,
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
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: fileUrl == null
                ? null
                : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          PdfViewerPage(url: fileUrl!, title: title),
                    ),
                  ),
            icon: const Icon(Icons.visibility_rounded),
            label: const Text('عرض الملف'),
          ),
        ],
      ),
    );
  }
}
