import 'package:equatable/equatable.dart';

class PreviousYearExamEntity extends Equatable {
  final int id;
  final String title;
  final int? subjectId;
  final String? subjectName;
  final int? year;
  final String? fileUrl;
  final String? description;

  const PreviousYearExamEntity({
    required this.id,
    required this.title,
    this.subjectId,
    this.subjectName,
    this.year,
    this.fileUrl,
    this.description,
  });

  @override
  List<Object?> get props => [id, title, year];
}
