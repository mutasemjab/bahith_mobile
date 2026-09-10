import '../../../../core/utils/json_parsing.dart';
import '../../domain/entities/question_bank_entity.dart';

class QuestionBankModel extends QuestionBankEntity {
  const QuestionBankModel({
    required super.id,
    required super.title,
    super.subjectId,
    super.subjectName,
    super.fileUrl,
    super.description,
    super.pages,
    super.fileSizeMb,
  });

  factory QuestionBankModel.fromJson(Map<String, dynamic> json) {
    final subject = json['subject'];
    return QuestionBankModel(
      id: json['id'],
      title: json['title'] ?? '',
      subjectId: toIntOrNull(subject is Map ? subject['id'] : null),
      subjectName: relatedName(subject) ?? json['subject_name'],
      fileUrl: json['pdf_url'] ?? json['file_url'] ?? json['file'],
      description: json['description'],
      pages: json['pages'] ?? 0,
      fileSizeMb: toDoubleOrNull(json['file_size']),
    );
  }
}
