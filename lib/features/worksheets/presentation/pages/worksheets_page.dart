import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../../core/widgets/pdf_resource_tile.dart';
import '../../domain/entities/worksheet_entity.dart';
import '../cubit/worksheets_cubit.dart';

class WorksheetsPage extends StatefulWidget {
  const WorksheetsPage({super.key});

  @override
  State<WorksheetsPage> createState() => _WorksheetsPageState();
}

class _WorksheetsPageState extends State<WorksheetsPage> {
  late final WorksheetsCubit _cubit = sl<WorksheetsCubit>()..loadFirstPage();
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
      appBar: AppBar(title: const Text('أوراق العمل')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _cubit.search,
              decoration: InputDecoration(
                hintText: 'ابحث عن ورقة عمل...',
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
            child: PaginatedListView<WorksheetEntity>(
              cubit: _cubit,
              emptyMessage: 'لا توجد أوراق عمل متاحة',
              emptyIcon: Icons.description_rounded,
              itemBuilder: (context, sheet) => PdfResourceTile(
                title: sheet.title,
                subtitle: [
                  if (sheet.subjectName != null) sheet.subjectName!,
                  if (sheet.year != null) '${sheet.year}',
                ].join(' · '),
                color: AppColors.success,
                onTap: () => context.push('/worksheets/${sheet.id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
