import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../../core/widgets/pdf_resource_tile.dart';
import '../../../previous_year_exams/domain/entities/previous_year_exam_entity.dart';
import '../../../previous_year_exams/presentation/cubit/previous_year_exams_cubit.dart';
import '../../../question_banks/domain/entities/question_bank_entity.dart';
import '../../../question_banks/presentation/cubit/question_banks_cubit.dart';
import '../../../worksheets/domain/entities/worksheet_entity.dart';
import '../../../worksheets/presentation/cubit/worksheets_cubit.dart';

/// Single "الملفات" screen with three tabs, each reusing the same
/// cubits/tiles as the standalone resource-list pages so the two entry
/// points (bottom nav tab vs. direct push) stay in sync.
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
      body: TabBarView(
        controller: _tabController,
        children: const [
          _PreviousYearExamsTab(),
          _QuestionBanksTab(),
          _WorksheetsTab(),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onSubmitted;
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textMuted,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
    );
  }
}

class _PreviousYearExamsTab extends StatefulWidget {
  const _PreviousYearExamsTab();
  @override
  State<_PreviousYearExamsTab> createState() => _PreviousYearExamsTabState();
}

class _PreviousYearExamsTabState extends State<_PreviousYearExamsTab>
    with AutomaticKeepAliveClientMixin {
  late final PreviousYearExamsCubit _cubit = sl<PreviousYearExamsCubit>()
    ..loadFirstPage();
  final _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _cubit.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        _SearchField(
          controller: _searchController,
          hint: 'ابحث عن امتحان...',
          onSubmitted: _cubit.search,
        ),
        Expanded(
          child: PaginatedListView<PreviousYearExamEntity>(
            cubit: _cubit,
            emptyMessage: 'لا توجد امتحانات سابقة متاحة',
            emptyIcon: Icons.history_edu_rounded,
            itemBuilder: (context, exam) => PdfResourceTile(
              title: exam.title,
              subtitle: [
                if (exam.subjectName != null) exam.subjectName!,
                if (exam.year != null) '${exam.year}',
              ].join(' · '),
              onTap: () => context.push('/previous-year-exams/${exam.id}'),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionBanksTab extends StatefulWidget {
  const _QuestionBanksTab();
  @override
  State<_QuestionBanksTab> createState() => _QuestionBanksTabState();
}

class _QuestionBanksTabState extends State<_QuestionBanksTab>
    with AutomaticKeepAliveClientMixin {
  late final QuestionBanksCubit _cubit = sl<QuestionBanksCubit>()
    ..loadFirstPage();
  final _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _cubit.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        _SearchField(
          controller: _searchController,
          hint: 'ابحث في بنوك الأسئلة...',
          onSubmitted: _cubit.search,
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
    );
  }
}

class _WorksheetsTab extends StatefulWidget {
  const _WorksheetsTab();
  @override
  State<_WorksheetsTab> createState() => _WorksheetsTabState();
}

class _WorksheetsTabState extends State<_WorksheetsTab>
    with AutomaticKeepAliveClientMixin {
  late final WorksheetsCubit _cubit = sl<WorksheetsCubit>()..loadFirstPage();
  final _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _cubit.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        _SearchField(
          controller: _searchController,
          hint: 'ابحث عن ورقة عمل...',
          onSubmitted: _cubit.search,
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
    );
  }
}
