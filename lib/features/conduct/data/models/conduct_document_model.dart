import '../../domain/entities/conduct_document_entity.dart';

class ConductDocumentModel extends ConductDocumentEntity {
  const ConductDocumentModel({
    required super.id,
    required super.titleAr,
    required super.titleEn,
    required super.body,
  });

  factory ConductDocumentModel.fromJson(Map<String, dynamic> json) =>
      ConductDocumentModel(
        id: json['id'] is int
            ? json['id'] as int
            : int.tryParse(json['id']?.toString() ?? '') ?? 0,
        titleAr: json['title_ar']?.toString() ?? 'مدونة السلوك',
        titleEn: json['title_en']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
      );
}

class ConductStatusModel extends ConductStatusEntity {
  const ConductStatusModel({required super.signed, super.documentId});

  factory ConductStatusModel.fromJson(Map<String, dynamic> json) =>
      ConductStatusModel(
        signed: json['signed'] == true,
        documentId: json['document_id'] is int
            ? json['document_id'] as int
            : int.tryParse(json['document_id']?.toString() ?? ''),
      );
}
