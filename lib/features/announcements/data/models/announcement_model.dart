import '../../domain/entities/announcement_entity.dart';

class AnnouncementModel extends AnnouncementEntity {
  const AnnouncementModel({
    required super.id,
    required super.title,
    required super.body,
    super.image,
    super.classId,
    super.publishedAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) =>
      AnnouncementModel(
        id: json['id'],
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        image: json['image'],
        classId: json['class_id'],
        publishedAt: json['published_at'],
      );
}
