import '../../../../core/utils/json_parsing.dart';
import '../../domain/entities/note_entity.dart';

class NoteModel extends NoteEntity {
  const NoteModel({
    required super.id,
    required super.title,
    super.type,
    super.content,
    super.fileUrl,
    super.subjectName,
    super.date,
    super.teacherName,
    super.className,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    final teacher = json['teacher'];
    return NoteModel(
      id: toInt(json['id']),
      title: json['title'] ?? '',
      type: json['type'],
      content: json['content'] ?? json['description'],
      fileUrl:
          json['attachment'] ??
          json['pdf_url'] ??
          json['file_url'] ??
          json['file'],
      subjectName: relatedName(json['subject']) ?? json['subject_name'],
      date: DateTime.tryParse(json['date']?.toString() ?? ''),
      teacherName: (teacher is Map ? teacher['name']?.toString() : null),
      className: json['class']?.toString(),
    );
  }
}
