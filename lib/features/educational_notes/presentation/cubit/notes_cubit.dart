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

  /// Groups notes by calendar day, drops days before today (the student
  /// only needs today-onward here), and sorts ascending so today comes
  /// first, matching how the notes screen is meant to be read.
  List<NoteDayGroupEntity> _groupByDay(List<NoteEntity> notes) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final groups = <DateTime, List<NoteEntity>>{};
    for (final note in notes) {
      final date = note.date;
      if (date == null) continue;
      final day = DateTime(date.year, date.month, date.day);
      if (day.isBefore(todayDate)) continue;
      groups.putIfAbsent(day, () => []).add(note);
    }

    final days = groups.keys.toList()..sort();
    return days
        .map((day) => NoteDayGroupEntity(date: day, notes: groups[day]!))
        .toList();
  }
}
