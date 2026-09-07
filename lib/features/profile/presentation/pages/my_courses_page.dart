import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../courses/domain/entities/course_entity.dart';
import '../../../courses/presentation/widgets/course_card.dart';
import '../cubit/my_courses_cubit.dart';

class MyCoursesPage extends StatefulWidget {
  const MyCoursesPage({super.key});

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  late final MyCoursesCubit _cubit = sl<MyCoursesCubit>()..loadFirstPage();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دوراتي')),
      body: PaginatedListView<CourseEntity>(
        cubit: _cubit,
        emptyMessage: 'لم تسجّل في أي دورة بعد',
        emptyIcon: Icons.menu_book_rounded,
        gridCrossAxisCount: 2,
        itemBuilder: (_, course) =>
            CourseCard(course: course, width: double.infinity),
      ),
    );
  }
}
