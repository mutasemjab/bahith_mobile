import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/models/subject_ref.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/subject_picker_view.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../previous_year_exams/domain/repositories/previous_year_exam_repository.dart';
import '../../../question_banks/domain/repositories/question_bank_repository.dart';
import '../../../worksheets/domain/repositories/worksheet_repository.dart';

/// Single "الملفات" screen with three tabs. Each tab starts with a
/// subject picker — same two-step flow (subject, then files) as the
/// standalone `/previous-year-exams`, `/question-banks` and `/worksheets`
/// entry points, so both paths land on the same filtered list route.
class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final classId = authState is AuthAuthenticated
        ? authState.student.classId
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملفات'),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
          tabs: const [
            Tab(text: 'أسئلة سنوات سابقة'),
            Tab(text: 'بنك الأسئلة'),
            Tab(text: 'أوراق العمل'),
          ],
        ),
      ),
      body: classId == null
          ? const EmptyState(
              message: 'تعذر تحديد صف الطالب',
              icon: Icons.error_outline_rounded,
            )
          : TabBarView(
              controller: _tabController,
              children: [
                SubjectPickerView(
                  key: const PageStorageKey('previous_year_exams'),
                  fetchSubjects: () => sl<PreviousYearExamRepository>()
                      .getSubjects(classId: classId),
                  onSelect: (context, subject) =>
                      _open(context, '/previous-year-exams/list', subject),
                ),
                SubjectPickerView(
                  key: const PageStorageKey('question_banks'),
                  fetchSubjects: () => sl<QuestionBankRepository>().getSubjects(
                    classId: classId,
                  ),
                  onSelect: (context, subject) =>
                      _open(context, '/question-banks/list', subject),
                ),
                SubjectPickerView(
                  key: const PageStorageKey('worksheets'),
                  fetchSubjects: () =>
                      sl<WorksheetRepository>().getSubjects(classId: classId),
                  onSelect: (context, subject) =>
                      _open(context, '/worksheets/list', subject),
                ),
              ],
            ),
    );
  }

  void _open(BuildContext context, String path, SubjectRef subject) {
    context.push(
      Uri(
        path: path,
        queryParameters: {
          'subject_id': '${subject.id}',
          'subject_name': subject.name,
        },
      ).toString(),
    );
  }
}
