import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_result.dart';
import '../../../../core/api/dio_error_mapper.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/json_parsing.dart';
import '../../../../core/utils/pagination.dart';
import '../../../auth/data/models/student_model.dart';
import '../../../auth/domain/entities/student_entity.dart';
import '../../../courses/data/models/course_model.dart';
import '../../../courses/domain/entities/course_entity.dart';
import '../../domain/entities/exam_attempt_entity.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/exam_attempt_model.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiClient _api;
  final SecureStorage _storage;
  const ProfileRepositoryImpl(this._api, this._storage);

  @override
  ApiResult<ProfileEntity> getProfile() async {
    try {
      final response = await _api.get(ApiEndpoints.profile);
      final data = response.data['data'] as Map<String, dynamic>;
      return Right(ProfileModel.fromJson(data));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<StudentEntity> updateProfile(UpdateProfilePayload payload) async {
    try {
      final fields = <String, dynamic>{
        if (payload.name != null) 'name': payload.name,
        if (payload.email != null) 'email': payload.email,
        if (payload.phone != null) 'phone': payload.phone,
        if (payload.gender != null) 'gender': payload.gender,
        if (payload.dateOfBirth != null) 'date_of_birth': payload.dateOfBirth,
        if (payload.nationality != null) 'nationality': payload.nationality,
        if (payload.classId != null) 'class_id': payload.classId,
        if (payload.password != null) 'password': payload.password,
        if (payload.passwordConfirmation != null)
          'password_confirmation': payload.passwordConfirmation,
        if (payload.currentPassword != null)
          'current_password': payload.currentPassword,
      };

      final Response response;
      if (payload.avatar != null) {
        final formData = FormData.fromMap({
          ...fields,
          '_method': 'PUT',
          'avatar': await MultipartFile.fromFile(payload.avatar!.path),
        });
        response = await _api.postFormData(ApiEndpoints.profile, formData);
      } else {
        response = await _api.put(ApiEndpoints.profile, data: fields);
      }

      final data = response.data['data'] as Map<String, dynamic>;
      final studentJson = unwrapResource(data, 'student');
      final student = StudentModel.fromJson(studentJson);
      await _storage.saveStudent(studentJson);
      return Right(student);
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<PaginatedResult<CourseEntity>> getMyCourses({
    required int page,
  }) async {
    try {
      final response = await _api.get(
        ApiEndpoints.myCourses,
        queryParams: {'page': page},
      );
      final list = response.data['data'] as List<dynamic>;
      final items = list
          .map((e) => _enrolledCourseFromJson(e as Map<String, dynamic>))
          .toList();
      final meta = response.data['pagination'] != null
          ? PaginationMeta.fromJson(response.data['pagination'])
          : PaginationMeta.single(items.length);
      return Right(PaginatedResult(items: items, meta: meta));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  /// `/my-courses` wraps each course in an enrollment record
  /// (`{ enrollment_id, progress_percentage, course: {...} }`) rather than
  /// returning the course fields flat — unwrap it and fold the
  /// enrollment-level progress into the course itself.
  CourseEntity _enrolledCourseFromJson(Map<String, dynamic> enrollment) {
    final courseJson = Map<String, dynamic>.from(
      unwrapResource(enrollment, 'course'),
    );
    courseJson['is_enrolled'] = true;
    final progressPercentage = toDoubleOrNull(
      enrollment['progress_percentage'],
    );
    if (progressPercentage != null) {
      courseJson['progress'] = progressPercentage / 100;
    }
    return CourseModel.fromJson(courseJson);
  }

  @override
  ApiResult<PaginatedResult<ExamAttemptEntity>> getMyExams({
    required int page,
  }) async {
    try {
      final response = await _api.get(
        ApiEndpoints.myExams,
        queryParams: {'page': page},
      );
      final list = response.data['data'] as List<dynamic>;
      final items = list
          .map((e) => ExamAttemptModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final meta = response.data['pagination'] != null
          ? PaginationMeta.fromJson(response.data['pagination'])
          : PaginationMeta.single(items.length);
      return Right(PaginatedResult(items: items, meta: meta));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
