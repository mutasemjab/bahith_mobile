import '../../../../core/utils/json_parsing.dart';
import '../../domain/entities/worksheet_entity.dart';

class WorksheetModel extends WorksheetEntity {
  const WorksheetModel({
    required super.id,
    required super.title,
    super.subjectId,
    super.subjectName,
    super.year,
    super.fileUrl,
    super.description,
  });

  factory WorksheetModel.fromJson(Map<String, dynamic> json) {
    final subject = json['subject'];
    return WorksheetModel(
      id: json['id'],
      title: json['title'] ?? '',
      subjectId: toIntOrNull(subject is Map ? subject['id'] : null),
      subjectName: relatedName(subject) ?? json['subject_name'],
      year: json['year'],
      fileUrl: json['pdf_url'] ?? json['file_url'] ?? json['file'],
      description: json['description'],
    );
  }
}
