import '../../../../core/utils/json_parsing.dart';
import '../../domain/entities/previous_year_exam_entity.dart';

class PreviousYearExamModel extends PreviousYearExamEntity {
  const PreviousYearExamModel({
    required super.id,
    required super.title,
    super.subjectName,
    super.year,
    super.fileUrl,
    super.description,
  });

  factory PreviousYearExamModel.fromJson(Map<String, dynamic> json) {
    return PreviousYearExamModel(
      id: json['id'],
      title: json['title'] ?? '',
      subjectName: relatedName(json['subject']) ?? json['subject_name'],
      year: json['year'],
      fileUrl: json['pdf_url'] ?? json['file_url'] ?? json['file'],
      description: json['description'],
    );
  }
}
