import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/note_entity.dart';
import '../utils/day_label.dart';
import '../widgets/note_tile.dart';

/// Split screen for a single day: lessons given (درس معطى) on top, homework
/// (واجب) on the bottom, so the student sees everything due that day at once.
class DailyNotesPage extends StatelessWidget {
  final NoteDayGroupEntity group;
  const DailyNotesPage({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(dayLabel(group.date))),
      body: Column(
        children: [
          Expanded(
            child: _NotesSection(
              title: 'دروس معطاة',
              icon: Icons.menu_book_rounded,
              color: AppColors.primary,
              notes: group.lessons,
              emptyMessage: 'لا يوجد درس معطى هذا اليوم',
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: _NotesSection(
              title: 'واجبات',
              icon: Icons.assignment_rounded,
              color: AppColors.gold,
              notes: group.homework,
              emptyMessage: 'لا يوجد واجب هذا اليوم',
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<NoteEntity> notes;
  final String emptyMessage;

  const _NotesSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.notes,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${notes.length}',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? Center(
                    child: Text(
                      emptyMessage,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    itemCount: notes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) =>
                        NoteTile(note: notes[i], accentColor: color),
                  ),
          ),
        ],
      ),
    );
  }
}
