import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../domain/entities/teacher_entity.dart';
import '../cubit/teachers_cubit.dart';
import '../widgets/teacher_card.dart';

class TeachersPage extends StatefulWidget {
  const TeachersPage({super.key});

  @override
  State<TeachersPage> createState() => _TeachersPageState();
}

class _TeachersPageState extends State<TeachersPage> {
  late final TeachersCubit _cubit = sl<TeachersCubit>()..loadFirstPage();
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
      appBar: AppBar(title: const Text('المعلمون')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _cubit.search,
              decoration: InputDecoration(
                hintText: 'ابحث عن معلم...',
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
            child: PaginatedListView<TeacherEntity>(
              cubit: _cubit,
              emptyMessage: 'لا يوجد معلمون مطابقون',
              emptyIcon: Icons.person_search_rounded,
              gridCrossAxisCount: 2,
              gridChildAspectRatio: 0.85,
              itemBuilder: (_, teacher) =>
                  TeacherCard(teacher: teacher, width: double.infinity),
            ),
          ),
        ],
      ),
    );
  }
}
