import '../../../../core/api/api_result.dart';
import '../entities/note_entity.dart';

abstract class NoteRepository {
  /// Fetches every page of the student's educational notes and returns them
  /// as a single flat list — the notes screen groups these by date itself,
  /// so there's no value in exposing pagination to the UI here.
  ApiResult<List<NoteEntity>> getAllNotes();
}
