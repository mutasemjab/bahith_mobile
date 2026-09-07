import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../../core/widgets/pdf_resource_tile.dart';
import '../../domain/entities/question_bank_entity.dart';
import '../cubit/question_banks_cubit.dart';

class QuestionBanksPage extends StatefulWidget {
  const QuestionBanksPage({super.key});

  @override
  State<QuestionBanksPage> createState() => _QuestionBanksPageState();
}

class _QuestionBanksPageState extends State<QuestionBanksPage> {
  late final QuestionBanksCubit _cubit = sl<QuestionBanksCubit>()
    ..loadFirstPage();
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
      appBar: AppBar(title: const Text('بنوك الأسئلة')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _cubit.search,
              decoration: InputDecoration(
                hintText: 'ابحث في بنوك الأسئلة...',
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
            child: PaginatedListView<QuestionBankEntity>(
              cubit: _cubit,
              emptyMessage: 'لا توجد بنوك أسئلة متاحة',
              emptyIcon: Icons.library_books_rounded,
              itemBuilder: (context, bank) => PdfResourceTile(
                title: bank.title,
                subtitle: [
                  if (bank.subjectName != null) bank.subjectName!,
                  if (bank.pagesAndSizeLabel.isNotEmpty) bank.pagesAndSizeLabel,
                ].join(' · '),
                color: AppColors.warning,
                onTap: () => context.push('/question-banks/${bank.id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
