import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_result.dart';
import '../../../../core/api/dio_error_mapper.dart';
import '../../domain/entities/course_content_entity.dart';
import '../../domain/repositories/course_content_repository.dart';
import '../models/course_content_model.dart';

class CourseContentRepositoryImpl implements CourseContentRepository {
  final ApiClient _api;
  const CourseContentRepositoryImpl(this._api);

  @override
  ApiResult<CourseContentEntity> getCourseContent(int courseId) async {
    try {
      final response = await _api.get(ApiEndpoints.courseUnits(courseId));
      final data = response.data['data'] as Map<String, dynamic>;
      return Right(CourseContentModel.fromJson(data));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<LessonDetailEntity> getLesson(int lessonId) async {
    try {
      final response = await _api.get(ApiEndpoints.lesson(lessonId));
      // Some detail endpoints on this API return the resource wrapped in
      // `data`, others return it flat — handle both defensively.
      final raw = response.data;
      final data = raw['data'] is Map
          ? raw['data'] as Map<String, dynamic>
          : raw as Map<String, dynamic>;
      return Right(LessonDetailModel.fromJson(data));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<void> saveLessonPosition({
    required int lessonId,
    required int watchSeconds,
  }) async {
    try {
      await _api.post(
        ApiEndpoints.lessonProgress(lessonId),
        data: {'watch_seconds': watchSeconds},
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<LessonProgressResultEntity> completeLesson({
    required int lessonId,
    int? watchSeconds,
  }) async {
    try {
      final response = await _api.post(
        ApiEndpoints.lessonProgress(lessonId),
        data: {'watch_seconds': ?watchSeconds, 'is_completed': true},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return Right(LessonProgressResultModel.fromJson(data));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<CourseProgressEntity> getCourseProgress(int courseId) async {
    try {
      final response = await _api.get(ApiEndpoints.courseMyProgress(courseId));
      final data = response.data['data'] as Map<String, dynamic>;
      return Right(CourseProgressModel.fromJson(data));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
