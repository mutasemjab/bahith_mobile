import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../domain/entities/note_entity.dart';
import '../pages/note_detail_page.dart';

void openNoteDetail(BuildContext context, NoteEntity note) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => NoteDetailPage(note: note)));
}

class NoteTile extends StatelessWidget {
  final NoteEntity note;
  final Color accentColor;
  const NoteTile({
    super.key,
    required this.note,
    this.accentColor = AppColors.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => openNoteDetail(context, note),
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
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  note.isPdfAttachment
                      ? Icons.picture_as_pdf_rounded
                      : note.isImageAttachment
                      ? Icons.image_rounded
                      : Icons.sticky_note_2_rounded,
                  color: accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (note.subjectName != null ||
                        note.teacherName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        [
                          note.subjectName,
                          note.teacherName,
                        ].whereType<String>().join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
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
    );
  }
}
