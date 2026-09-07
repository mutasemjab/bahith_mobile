import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/repositories/course_repository.dart';
import '../cubit/courses_cubit.dart';
import '../widgets/course_card.dart';

class CoursesPage extends StatefulWidget {
  final int? categoryId;
  final int? subjectId;
  final int? teacherId;
  final bool featured;
  final bool trending;

  const CoursesPage({
    super.key,
    this.categoryId,
    this.subjectId,
    this.teacherId,
    this.featured = false,
    this.trending = false,
  });

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  late final CoursesCubit _cubit = sl<CoursesCubit>(
    param1: CourseFilters(
      categoryId: widget.categoryId,
      subjectId: widget.subjectId,
      teacherId: widget.teacherId,
      featured: widget.featured ? true : null,
      trending: widget.trending ? true : null,
    ),
  )..loadFirstPage();

  final _searchController = TextEditingController();

  @override
  void dispose() {
    _cubit.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.trending
        ? 'الأكثر رواجاً'
        : widget.featured
        ? 'دورات مميزة'
        : 'الدورات';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _cubit.search,
              decoration: InputDecoration(
                hintText: 'ابحث عن دورة...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textMuted,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _cubit.search('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            ),
          ),
          Expanded(
            child: PaginatedListView<CourseEntity>(
              cubit: _cubit,
              emptyMessage: 'لا توجد دورات مطابقة',
              emptyIcon: Icons.menu_book_rounded,
              gridCrossAxisCount: 2,
              itemBuilder: (_, course) =>
                  CourseCard(course: course, width: double.infinity),
            ),
          ),
        ],
      ),
    );
  }
}
