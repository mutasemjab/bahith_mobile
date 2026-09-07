import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/resource_pdf_detail_view.dart';
import '../../domain/entities/previous_year_exam_entity.dart';
import '../cubit/previous_year_exam_detail_cubit.dart';

class PreviousYearExamDetailPage extends StatelessWidget {
  final int examId;
  const PreviousYearExamDetailPage({super.key, required this.examId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PreviousYearExamDetailCubit>()..load(examId),
      child: Scaffold(
        appBar: AppBar(title: const Text('امتحان سابق')),
        body:
            BlocBuilder<
              PreviousYearExamDetailCubit,
              ResourceState<PreviousYearExamEntity>
            >(
              builder: (context, state) {
                if (state is ResourceLoading) return const LoadingWidget();
                if (state is ResourceError<PreviousYearExamEntity>) {
                  return AppErrorView(
                    message: state.message,
                    onRetry: () => context
                        .read<PreviousYearExamDetailCubit>()
                        .load(examId),
                  );
                }
                final exam =
                    (state as ResourceLoaded<PreviousYearExamEntity>).data;
                return ResourcePdfDetailView(
                  title: exam.title,
                  badges: [
                    if (exam.subjectName != null) exam.subjectName!,
                    if (exam.year != null) '${exam.year}',
                  ],
                  description: exam.description,
                  fileUrl: exam.fileUrl,
                );
              },
            ),
      ),
    );
  }
}
