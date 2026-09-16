import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../../../core/widgets/pdf_viewer_page.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/note_entity.dart';

class NoteDetailPage extends StatelessWidget {
  final NoteEntity note;
  const NoteDetailPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(note.isHomework ? 'واجب' : 'درس معطى')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (note.images.length == 1)
            GestureDetector(
              onTap: () => showImageGallery(context, note.images),
              child: AppNetworkImage(
                url: note.images.first,
                height: 220,
                width: double.infinity,
                radius: 0,
                fallbackIcon: Icons.image_rounded,
              ),
            )
          else if (note.images.length > 1)
            _NoteImagesStrip(images: note.images),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    StatusBadge(
                      label: note.isHomework ? 'واجب' : 'درس معطى',
                      color: note.isHomework
                          ? AppColors.gold
                          : AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  children: [
                    if (note.date != null)
                      _MetaItem(
                        icon: Icons.schedule_rounded,
                        label: note.date!.arDate,
                      ),
                    if (note.subjectName != null)
                      _MetaItem(
                        icon: Icons.menu_book_rounded,
                        label: note.subjectName!,
                      ),
                    if (note.teacherName != null)
                      _MetaItem(
                        icon: Icons.person_rounded,
                        label: note.teacherName!,
                      ),
                  ],
                ),
                if (note.content != null && note.content!.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    note.content!,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: AppColors.textPrimary,
                      height: 1.8,
                    ),
                  ),
                ],
                if (note.isPdfAttachment) ...[
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PdfViewerPage(
                          url: note.fileUrl!,
                          title: note.title,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.picture_as_pdf_rounded),
                    label: const Text('فتح المرفق'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

/// Horizontal thumbnail strip shown when a note has more than one image —
/// tapping any thumbnail opens the swipeable gallery starting at it.
class _NoteImagesStrip extends StatelessWidget {
  final List<String> images;
  const _NoteImagesStrip({required this.images});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        itemCount: images.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => showImageGallery(context, images, initialIndex: i),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: AppNetworkImage(
              url: images[i],
              width: 96,
              height: 96,
              radius: AppRadius.sm,
              fallbackIcon: Icons.image_rounded,
            ),
          ),
        ),
      ),
    );
  }
}
