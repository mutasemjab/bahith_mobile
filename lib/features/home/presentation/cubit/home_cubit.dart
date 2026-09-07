import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repository;
  HomeCubit(this._repository) : super(const HomeLoading());

  Future<void> load() async {
    emit(const HomeLoading());
    final result = await _repository.getHome();
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (home) => emit(HomeLoaded(home)),
    );
  }
}
