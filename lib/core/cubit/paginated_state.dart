import 'package:equatable/equatable.dart';

abstract class PaginatedState<T> extends Equatable {
  const PaginatedState();
  @override
  List<Object?> get props => [];
}

class PaginatedInitial<T> extends PaginatedState<T> {
  const PaginatedInitial();
}

class PaginatedLoading<T> extends PaginatedState<T> {
  const PaginatedLoading();
}

class PaginatedLoaded<T> extends PaginatedState<T> {
  final List<T> items;
  final bool hasMore;
  final bool isLoadingMore;

  const PaginatedLoaded({
    required this.items,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  PaginatedLoaded<T> copyWith({
    List<T>? items,
    bool? hasMore,
    bool? isLoadingMore,
  }) => PaginatedLoaded<T>(
    items: items ?? this.items,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );

  @override
  List<Object?> get props => [items, hasMore, isLoadingMore];
}

class PaginatedError<T> extends PaginatedState<T> {
  final String message;
  const PaginatedError(this.message);
  @override
  List<Object?> get props => [message];
}
