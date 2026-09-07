import 'package:equatable/equatable.dart';

class WorksheetEntity extends Equatable {
  final int id;
  final String title;
  final String? subjectName;
  final int? year;
  final String? fileUrl;
  final String? description;

  const WorksheetEntity({
    required this.id,
    required this.title,
    this.subjectName,
    this.year,
    this.fileUrl,
    this.description,
  });

  @override
  List<Object?> get props => [id, title, year];
}
