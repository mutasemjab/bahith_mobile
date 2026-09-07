import 'package:equatable/equatable.dart';

class ConductDocumentEntity extends Equatable {
  final int id;
  final String titleAr;
  final String titleEn;
  final String body;

  const ConductDocumentEntity({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.body,
  });

  @override
  List<Object?> get props => [id, titleAr, titleEn, body];
}

class ConductStatusEntity extends Equatable {
  final bool signed;
  final int? documentId;

  const ConductStatusEntity({required this.signed, this.documentId});

  @override
  List<Object?> get props => [signed, documentId];
}
