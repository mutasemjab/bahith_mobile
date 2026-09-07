import 'package:equatable/equatable.dart';

/// Generic loading/loaded/error state for single-resource fetches
/// (detail screens, profile, home) — as opposed to [PaginatedState] lists.
abstract class ResourceState<T> extends Equatable {
  const ResourceState();
  @override
  List<Object?> get props => [];
}

class ResourceLoading<T> extends ResourceState<T> {
  const ResourceLoading();
}

class ResourceLoaded<T> extends ResourceState<T> {
  final T data;
  const ResourceLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class ResourceError<T> extends ResourceState<T> {
  final String message;
  const ResourceError(this.message);
  @override
  List<Object?> get props => [message];
}
