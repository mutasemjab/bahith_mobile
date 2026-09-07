import '../../../../core/utils/json_parsing.dart';
import '../../../auth/data/models/student_model.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileStatsModel extends ProfileStatsEntity {
  const ProfileStatsModel({
    super.coursesCount,
    super.examsCount,
    super.averageScore,
  });

  factory ProfileStatsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ProfileStatsModel();
    return ProfileStatsModel(
      coursesCount: json['total_courses'] ?? json['courses_count'] ?? 0,
      examsCount: json['total_exams'] ?? json['exams_count'] ?? 0,
      averageScore: toDouble(json['average_score']),
    );
  }
}

class ProfileModel extends ProfileEntity {
  const ProfileModel({required super.student, required super.stats});

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    student: StudentModel.fromJson(unwrapResource(json, 'student')),
    stats: ProfileStatsModel.fromJson(json['stats'] as Map<String, dynamic>?),
  );
}
