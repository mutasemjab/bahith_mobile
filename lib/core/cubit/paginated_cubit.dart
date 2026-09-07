import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../errors/failure.dart';
import '../utils/pagination.dart';
import 'paginated_state.dart';

/// Base cubit implementing the fetch-first-page / infinite-scroll-load-more
/// pattern shared by every list screen (courses, teachers, exams, ...).
/// Subclasses only implement [fetchPage].
abstract class PaginatedCubit<T> extends Cubit<PaginatedState<T>> {
  PaginatedCubit() : super(const PaginatedInitial());

  int _page = 1;

  Future<Either<Failure, PaginatedResult<T>>> fetchPage(int page);

  Future<void> loadFirstPage() async {
    emit(const PaginatedLoading());
    _page = 1;
    try {
      final result = await fetchPage(_page);
      result.fold(
        (failure) => emit(PaginatedError(failure.message)),
        (paginated) => emit(
          PaginatedLoaded(
            items: paginated.items,
            hasMore: paginated.meta.hasNextPage,
          ),
        ),
      );
    } catch (_) {
      // A parsing exception (e.g. an unexpected field shape from the API)
      // isn't a Failure and would otherwise propagate uncaught, leaving
      // the UI stuck on the loading spinner forever — surface it as a
      // normal error state instead.
      emit(const PaginatedError('حدث خطأ غير متوقع، حاول مجدداً'));
    }
  }

  Future<void> refresh() => loadFirstPage();

  Future<void> loadMore() async {
    final current = state;
    if (current is! PaginatedLoaded<T> ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));

    final nextPage = _page + 1;
    try {
      final result = await fetchPage(nextPage);
      result.fold((_) => emit(current.copyWith(isLoadingMore: false)), (
        paginated,
      ) {
        _page = nextPage;
        emit(
          PaginatedLoaded(
            items: [...current.items, ...paginated.items],
            hasMore: paginated.meta.hasNextPage,
          ),
        );
      });
    } catch (_) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }
}
