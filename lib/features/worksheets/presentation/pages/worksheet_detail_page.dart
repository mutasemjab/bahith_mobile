import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/resource_pdf_detail_view.dart';
import '../../domain/entities/worksheet_entity.dart';
import '../cubit/worksheet_detail_cubit.dart';

class WorksheetDetailPage extends StatelessWidget {
  final int worksheetId;
  const WorksheetDetailPage({super.key, required this.worksheetId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WorksheetDetailCubit>()..load(worksheetId),
      child: Scaffold(
        appBar: AppBar(title: const Text('ورقة عمل')),
        body: BlocBuilder<WorksheetDetailCubit, ResourceState<WorksheetEntity>>(
          builder: (context, state) {
            if (state is ResourceLoading) return const LoadingWidget();
            if (state is ResourceError<WorksheetEntity>) {
              return AppErrorView(
                message: state.message,
                onRetry: () =>
                    context.read<WorksheetDetailCubit>().load(worksheetId),
              );
            }
            final sheet = (state as ResourceLoaded<WorksheetEntity>).data;
            return ResourcePdfDetailView(
              title: sheet.title,
              badges: [
                if (sheet.subjectName != null) sheet.subjectName!,
                if (sheet.year != null) '${sheet.year}',
              ],
              description: sheet.description,
              fileUrl: sheet.fileUrl,
            );
          },
        ),
      ),
    );
  }
}
