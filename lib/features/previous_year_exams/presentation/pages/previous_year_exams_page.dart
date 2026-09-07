import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/pdf_resource_tile.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../domain/entities/previous_year_exam_entity.dart';
import '../cubit/previous_year_exams_cubit.dart';

class PreviousYearExamsPage extends StatefulWidget {
  const PreviousYearExamsPage({super.key});

  @override
  State<PreviousYearExamsPage> createState() => _PreviousYearExamsPageState();
}

class _PreviousYearExamsPageState extends State<PreviousYearExamsPage> {
  late final PreviousYearExamsCubit _cubit = sl<PreviousYearExamsCubit>()
    ..loadFirstPage();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _cubit.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('امتحانات الأعوام السابقة')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _cubit.search,
              decoration: InputDecoration(
                hintText: 'ابحث عن امتحان...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textMuted,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            ),
          ),
          Expanded(
            child: PaginatedListView<PreviousYearExamEntity>(
              cubit: _cubit,
              emptyMessage: 'لا توجد امتحانات سابقة متاحة',
              emptyIcon: Icons.history_edu_rounded,
              itemBuilder: (context, exam) => PdfResourceTile(
                title: exam.title,
                subtitle: [
                  if (exam.subjectName != null) exam.subjectName!,
                  if (exam.year != null) '${exam.year}',
                ].join(' · '),
                onTap: () => context.push('/previous-year-exams/${exam.id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
