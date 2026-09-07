import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/resource_pdf_detail_view.dart';
import '../../domain/entities/question_bank_entity.dart';
import '../cubit/question_bank_detail_cubit.dart';

class QuestionBankDetailPage extends StatelessWidget {
  final int bankId;
  const QuestionBankDetailPage({super.key, required this.bankId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<QuestionBankDetailCubit>()..load(bankId),
      child: Scaffold(
        appBar: AppBar(title: const Text('بنك الأسئلة')),
        body:
            BlocBuilder<
              QuestionBankDetailCubit,
              ResourceState<QuestionBankEntity>
            >(
              builder: (context, state) {
                if (state is ResourceLoading) return const LoadingWidget();
                if (state is ResourceError<QuestionBankEntity>) {
                  return AppErrorView(
                    message: state.message,
                    onRetry: () =>
                        context.read<QuestionBankDetailCubit>().load(bankId),
                  );
                }
                final bank = (state as ResourceLoaded<QuestionBankEntity>).data;
                return ResourcePdfDetailView(
                  title: bank.title,
                  badges: [
                    if (bank.subjectName != null) bank.subjectName!,
                    if (bank.pagesAndSizeLabel.isNotEmpty)
                      bank.pagesAndSizeLabel,
                  ],
                  description: bank.description,
                  fileUrl: bank.fileUrl,
                );
              },
            ),
      ),
    );
  }
}
