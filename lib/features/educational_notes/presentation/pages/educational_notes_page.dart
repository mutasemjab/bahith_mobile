import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/note_entity.dart';
import '../cubit/notes_cubit.dart';
import '../utils/day_label.dart';
import 'daily_notes_page.dart';

class EducationalNotesPage extends StatefulWidget {
  const EducationalNotesPage({super.key});

  @override
  State<EducationalNotesPage> createState() => _EducationalNotesPageState();
}

class _EducationalNotesPageState extends State<EducationalNotesPage> {
  late final NotesCubit _cubit = sl<NotesCubit>()..load();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الملاحظات التعليمية')),
      body: BlocBuilder<NotesCubit, ResourceState<List<NoteDayGroupEntity>>>(
        bloc: _cubit,
        builder: (context, state) {
          if (state is ResourceLoading) return const LoadingWidget();
          if (state is ResourceError<List<NoteDayGroupEntity>>) {
            return AppErrorView(message: state.message, onRetry: _cubit.load);
          }
          final groups =
              (state as ResourceLoaded<List<NoteDayGroupEntity>>).data;
          if (groups.isEmpty) {
            return const EmptyState(
              message: 'لا توجد ملاحظات قادمة لصفك حالياً',
              icon: Icons.sticky_note_2_rounded,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _DayCard(group: groups[i]),
          );
        },
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final NoteDayGroupEntity group;
  const _DayCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final lessonsCount = group.lessons.length;
    final homeworkCount = group.homework.length;
    final parts = <String>[
      if (lessonsCount > 0) '$lessonsCount درس معطى',
      if (homeworkCount > 0) '$homeworkCount واجب',
    ];

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => DailyNotesPage(group: group))),
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
                  Icons.calendar_today_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayLabel(group.date),
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      parts.isEmpty ? 'لا يوجد محتوى' : parts.join(' · '),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
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
