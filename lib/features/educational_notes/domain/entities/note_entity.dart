import 'package:equatable/equatable.dart';

/// `type` is either `lesson` (درس معطى) or `homework` (واجب).
class NoteEntity extends Equatable {
  final int id;
  final String title;
  final String? type;
  final String? content;
  final String? fileUrl;
  final String? subjectName;
  final DateTime? date;
  final String? teacherName;
  final String? className;

  /// Every image attached to this note, in upload order — a note can now
  /// carry more than one. [fileUrl] mirrors the first entry for backward
  /// compatibility only; prefer this list.
  final List<String> images;

  const NoteEntity({
    required this.id,
    required this.title,
    this.type,
    this.content,
    this.fileUrl,
    this.subjectName,
    this.date,
    this.teacherName,
    this.className,
    this.images = const [],
  });

  bool get isHomework => type == 'homework';
  bool get isLesson => type == 'lesson';

  /// The attachment this API sends for notes is almost always a photo of
  /// the board/homework, not a document — only treat it as a PDF if the
  /// URL actually says so, otherwise show it as an image.
  bool get isPdfAttachment => fileUrl?.toLowerCase().endsWith('.pdf') ?? false;
  bool get isImageAttachment => fileUrl != null && !isPdfAttachment;

  @override
  List<Object?> get props => [id, title, type, date];
}

/// All of a single calendar day's notes, split by [NoteEntity.type].
class NoteDayGroupEntity extends Equatable {
  final DateTime date;
  final List<NoteEntity> notes;

  const NoteDayGroupEntity({required this.date, required this.notes});

  List<NoteEntity> get lessons => notes.where((n) => n.isLesson).toList();
  List<NoteEntity> get homework => notes.where((n) => n.isHomework).toList();

  @override
  List<Object?> get props => [date, notes];
}
