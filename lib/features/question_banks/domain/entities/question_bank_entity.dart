import 'package:equatable/equatable.dart';

class QuestionBankEntity extends Equatable {
  final int id;
  final String title;
  final String? subjectName;
  final String? fileUrl;
  final String? description;
  final int pages;
  final double? fileSizeMb;

  const QuestionBankEntity({
    required this.id,
    required this.title,
    this.subjectName,
    this.fileUrl,
    this.description,
    this.pages = 0,
    this.fileSizeMb,
  });

  /// e.g. "10 صفحة · 25 م.ب" — omits whichever half is missing.
  String get pagesAndSizeLabel {
    final parts = [
      if (pages > 0) '$pages صفحة',
      if (fileSizeMb != null) '${fileSizeMb!.toStringAsFixed(0)} م.ب',
    ];
    return parts.join(' · ');
  }

  @override
  List<Object?> get props => [id, title];
}
