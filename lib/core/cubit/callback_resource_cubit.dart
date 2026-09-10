import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/api_result.dart';
import 'resource_state.dart';

/// A [ResourceState] cubit driven by a plain fetch callback instead of a
/// dedicated repository/DI registration — for one-off screens (like a
/// subject picker) that would otherwise need a near-identical cubit class
/// per feature just to call a single repository method.
class CallbackResourceCubit<T> extends Cubit<ResourceState<T>> {
  final ApiResult<T> Function() _fetch;
  CallbackResourceCubit(this._fetch) : super(const ResourceLoading());

  Future<void> load() async {
    emit(const ResourceLoading());
    final result = await _fetch();
    result.fold(
      (failure) => emit(ResourceError(failure.message)),
      (data) => emit(ResourceLoaded(data)),
    );
  }
}
