import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../domain/entities/exam_entity.dart';
import '../cubit/exams_cubit.dart';
import '../widgets/exam_list_tile.dart';

class ExamsPage extends StatefulWidget {
  const ExamsPage({super.key});

  @override
  State<ExamsPage> createState() => _ExamsPageState();
}

class _ExamsPageState extends State<ExamsPage> {
  late final ExamsCubit _cubit = sl<ExamsCubit>()..loadFirstPage();
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
      appBar: AppBar(title: const Text('الاختبارات')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _cubit.search,
              decoration: InputDecoration(
                hintText: 'ابحث عن اختبار...',
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
            child: PaginatedListView<ExamEntity>(
              cubit: _cubit,
              emptyMessage: 'لا توجد اختبارات متاحة',
              emptyIcon: Icons.quiz_rounded,
              itemBuilder: (_, exam) => ExamListTile(exam: exam),
            ),
          ),
        ],
      ),
    );
  }
}
