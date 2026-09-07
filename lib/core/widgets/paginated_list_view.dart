import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/paginated_cubit.dart';
import '../cubit/paginated_state.dart';
import '../theme/app_colors.dart';
import 'app_error_view.dart';
import 'empty_state.dart';
import 'loading_widget.dart';

/// Drives any [PaginatedCubit] screen: loading skeleton, error + retry,
/// empty state, pull-to-refresh and infinite scroll — implemented once.
///
/// Takes the cubit instance directly (rather than resolving it from context)
/// so callers can pass any concrete subclass of `PaginatedCubit<T>` without
/// fighting provider's exact-generic-type lookup.
class PaginatedListView<T> extends StatelessWidget {
  final PaginatedCubit<T> cubit;
  final Widget Function(BuildContext, T index) itemBuilder;
  final Widget Function(BuildContext)? loadingBuilder;
  final String emptyMessage;
  final IconData emptyIcon;
  final Axis scrollDirection;
  final EdgeInsets padding;
  final Widget? separator;
  final int? gridCrossAxisCount;
  final double? gridChildAspectRatio;

  const PaginatedListView({
    super.key,
    required this.cubit,
    required this.itemBuilder,
    this.loadingBuilder,
    this.emptyMessage = 'لا توجد عناصر لعرضها حالياً',
    this.emptyIcon = Icons.inbox_rounded,
    this.scrollDirection = Axis.vertical,
    this.padding = const EdgeInsets.all(16),
    this.separator,
    this.gridCrossAxisCount,
    this.gridChildAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaginatedCubit<T>, PaginatedState<T>>(
      bloc: cubit,
      builder: (context, state) {
        if (state is PaginatedInitial<T> || state is PaginatedLoading<T>) {
          return loadingBuilder?.call(context) ?? const LoadingWidget();
        }

        if (state is PaginatedError<T>) {
          return AppErrorView(
            message: state.message,
            onRetry: cubit.loadFirstPage,
          );
        }

        final loaded = state as PaginatedLoaded<T>;
        if (loaded.items.isEmpty) {
          return EmptyState(message: emptyMessage, icon: emptyIcon);
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: cubit.refresh,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scroll) {
              if (scroll.metrics.pixels >=
                      scroll.metrics.maxScrollExtent - 240 &&
                  loaded.hasMore &&
                  !loaded.isLoadingMore) {
                cubit.loadMore();
              }
              return false;
            },
            child: gridCrossAxisCount != null
                ? GridView.builder(
                    padding: padding,
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridCrossAxisCount!,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: gridChildAspectRatio ?? 0.72,
                    ),
                    itemCount: loaded.items.length,
                    itemBuilder: (ctx, i) => itemBuilder(ctx, loaded.items[i]),
                  )
                : ListView.separated(
                    padding: padding,
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: scrollDirection,
                    itemCount:
                        loaded.items.length + (loaded.isLoadingMore ? 1 : 0),
                    separatorBuilder: (_, _) =>
                        separator ?? const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      if (i == loaded.items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: LoadingWidget(size: 22),
                        );
                      }
                      return itemBuilder(ctx, loaded.items[i]);
                    },
                  ),
          ),
        );
      },
    );
  }
}
