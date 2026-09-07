import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/conduct_repository.dart';
import 'conduct_state.dart';

class ConductCubit extends Cubit<ConductState> {
  final ConductRepository _repository;

  ConductCubit(this._repository) : super(const ConductLoading());

  Future<void> load() async {
    emit(const ConductLoading());
    final result = await _repository.getDocument();
    result.fold(
      (failure) => emit(ConductLoadError(failure.message)),
      (document) => emit(ConductLoaded(document)),
    );
  }

  Future<void> sign(String guardianName) async {
    final current = state;
    if (current is! ConductLoaded || current.submitting) return;

    emit(ConductLoaded(current.document, submitting: true));
    final result = await _repository.sign(guardianName: guardianName);
    result.fold(
      (failure) =>
          emit(ConductLoaded(current.document, errorMessage: failure.message)),
      (_) => emit(const ConductSignSuccess()),
    );
  }
}
