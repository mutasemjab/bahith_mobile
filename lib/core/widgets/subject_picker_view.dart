import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/api_result.dart';
import '../cubit/callback_resource_cubit.dart';
import '../cubit/resource_state.dart';
import '../models/subject_ref.dart';
import '../theme/app_colors.dart';
import 'app_error_view.dart';
import 'empty_state.dart';
import 'loading_widget.dart';

/// Body-only "pick a subject" grid — the first step before browsing a
/// class-scoped resource list (question banks, previous-year exams,
/// worksheets). Has no [Scaffold]/[AppBar] of its own so it can be reused
/// both as a standalone route's body and as a [TabBarView] page.
class SubjectPickerView extends StatefulWidget {
  final ApiResult<List<SubjectRef>> Function() fetchSubjects;
  final void Function(BuildContext context, SubjectRef subject) onSelect;
  final String emptyMessage;

  const SubjectPickerView({
    super.key,
    required this.fetchSubjects,
    required this.onSelect,
    this.emptyMessage = 'لا توجد مواد متاحة لصفك حالياً',
  });

  @override
  State<SubjectPickerView> createState() => _SubjectPickerViewState();
}

class _SubjectPickerViewState extends State<SubjectPickerView>
    with AutomaticKeepAliveClientMixin {
  late final CallbackResourceCubit<List<SubjectRef>> _cubit =
      CallbackResourceCubit<List<SubjectRef>>(widget.fetchSubjects)..load();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<
      CallbackResourceCubit<List<SubjectRef>>,
      ResourceState<List<SubjectRef>>
    >(
      bloc: _cubit,
      builder: (context, state) {
        if (state is ResourceLoading<List<SubjectRef>>) {
          return const LoadingWidget();
        }
        if (state is ResourceError<List<SubjectRef>>) {
          return AppErrorView(message: state.message, onRetry: _cubit.load);
        }

        final subjects = (state as ResourceLoaded<List<SubjectRef>>).data;
        if (subjects.isEmpty) {
          return EmptyState(
            message: widget.emptyMessage,
            icon: Icons.menu_book_rounded,
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _cubit.load,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 18,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: subjects.length,
            itemBuilder: (_, i) => _SubjectTile(
              subject: subjects[i],
              index: i,
              onTap: () => widget.onSelect(context, subjects[i]),
            ),
          ),
        );
      },
    );
  }
}

class _SubjectTile extends StatelessWidget {
  final SubjectRef subject;
  final int index;
  final VoidCallback onTap;

  const _SubjectTile({
    required this.subject,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.gradientForIndex(index);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subject.name,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
