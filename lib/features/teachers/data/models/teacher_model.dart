import '../../../../core/utils/json_parsing.dart';
import '../../domain/entities/teacher_entity.dart';

class TeacherModel extends TeacherEntity {
  const TeacherModel({
    required super.id,
    required super.name,
    super.avatar,
    super.bio,
    super.specialization,
    super.coursesCount,
    super.rating,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) => TeacherModel(
    id: json['id'],
    name: json['name'] ?? '',
    avatar: json['avatar'],
    bio: json['bio'],
    specialization: json['specialization'],
    coursesCount: json['total_courses'] ?? json['courses_count'] ?? 0,
    rating: toDouble(json['average_rating'] ?? json['rating']),
  );
}
