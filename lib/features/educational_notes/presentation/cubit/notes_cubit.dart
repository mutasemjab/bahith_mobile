import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/note_repository.dart';

class NotesCubit extends Cubit<ResourceState<List<NoteDayGroupEntity>>> {
  final NoteRepository _repository;
  NotesCubit(this._repository) : super(const ResourceLoading());

  Future<void> load() async {
    emit(const ResourceLoading());
    final result = await _repository.getAllNotes();
    result.fold(
      (failure) => emit(ResourceError(failure.message)),
      (notes) => emit(ResourceLoaded(_groupByDay(notes))),
    );
  }

  /// Groups notes by calendar day, keeping the backend's order. No date
  /// filtering or sorting happens here — the backend owns both.
  List<NoteDayGroupEntity> _groupByDay(List<NoteEntity> notes) {
    final groups = <DateTime, List<NoteEntity>>{};
    for (final note in notes) {
      final date = note.date;
      if (date == null) continue;
      final day = DateTime(date.year, date.month, date.day);
      groups.putIfAbsent(day, () => []).add(note);
    }

    return groups.entries
        .map((e) => NoteDayGroupEntity(date: e.key, notes: e.value))
        .toList();
  }
}
