import 'dart:io';

import '../../../../core/api/api_result.dart';
import '../../../../core/utils/pagination.dart';
import '../../../auth/domain/entities/student_entity.dart';
import '../../../courses/domain/entities/course_entity.dart';
import '../entities/exam_attempt_entity.dart';
import '../entities/profile_entity.dart';

class UpdateProfilePayload {
  final String? name;
  final String? email;
  final String? phone;
  final String? gender;
  final String? dateOfBirth;
  final String? nationality;
  final int? classId;
  final File? avatar;
  final String? password;
  final String? passwordConfirmation;
  final String? currentPassword;

  const UpdateProfilePayload({
    this.name,
    this.email,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.nationality,
    this.classId,
    this.avatar,
    this.password,
    this.passwordConfirmation,
    this.currentPassword,
  });
}

abstract class ProfileRepository {
  ApiResult<ProfileEntity> getProfile();
  ApiResult<StudentEntity> updateProfile(UpdateProfilePayload payload);
  ApiResult<PaginatedResult<CourseEntity>> getMyCourses({required int page});
  ApiResult<PaginatedResult<ExamAttemptEntity>> getMyExams({required int page});
}
