import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/models/subject_ref.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/subject_picker_view.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/repositories/previous_year_exam_repository.dart';

/// Entry point for "أسئلة سنوات سابقة" — pick a subject first, then browse
/// that subject's exams.
class PreviousYearExamSubjectsPage extends StatelessWidget {
  const PreviousYearExamSubjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final classId = authState is AuthAuthenticated
        ? authState.student.classId
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('امتحانات الأعوام السابقة')),
      body: classId == null
          ? const EmptyState(
              message: 'تعذر تحديد صف الطالب',
              icon: Icons.error_outline_rounded,
            )
          : SubjectPickerView(
              fetchSubjects: () => sl<PreviousYearExamRepository>().getSubjects(
                classId: classId,
              ),
              onSelect: (context, subject) => _openSubject(context, subject),
            ),
    );
  }

  void _openSubject(BuildContext context, SubjectRef subject) {
    context.push(
      Uri(
        path: '/previous-year-exams/list',
        queryParameters: {
          'subject_id': '${subject.id}',
          'subject_name': subject.name,
        },
      ).toString(),
    );
  }
}
