import 'package:equatable/equatable.dart';

class AnnouncementEntity extends Equatable {
  final int id;
  final String title;
  final String body;
  final String? image;
  final int? classId;
  final String? publishedAt;

  const AnnouncementEntity({
    required this.id,
    required this.title,
    required this.body,
    this.image,
    this.classId,
    this.publishedAt,
  });

  @override
  List<Object?> get props => [id, title, publishedAt];
}
