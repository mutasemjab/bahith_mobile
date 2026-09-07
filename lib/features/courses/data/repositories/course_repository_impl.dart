import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_result.dart';
import '../../../../core/api/dio_error_mapper.dart';
import '../../../../core/utils/json_parsing.dart';
import '../../../../core/utils/pagination.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/repositories/course_repository.dart';
import '../models/course_model.dart';

class CourseRepositoryImpl implements CourseRepository {
  final ApiClient _api;
  const CourseRepositoryImpl(this._api);

  @override
  ApiResult<PaginatedResult<CourseEntity>> getCourses({
    required int page,
    CourseFilters filters = const CourseFilters(),
  }) async {
    try {
      final response = await _api.get(
        ApiEndpoints.courses,
        queryParams: {'page': page, ...filters.toQuery()},
      );
      final list = response.data['data'] as List<dynamic>;
      final items = list
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final meta = response.data['pagination'] != null
          ? PaginationMeta.fromJson(response.data['pagination'])
          : PaginationMeta.single(items.length);
      return Right(PaginatedResult(items: items, meta: meta));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<CourseEntity> getCourse(int id) async {
    try {
      final response = await _api.get(ApiEndpoints.course(id));
      final data = response.data['data'] as Map<String, dynamic>;
      final course = CourseModel.fromJson(unwrapResource(data, 'course'));

      // `/courses/{id}` never actually reports enrollment or progress (its
      // response has no `is_enrolled`/`progress` keys at all, confirmed
      // from a real activated-course response) — cross-check against the
      // units endpoint, which does return `is_enrolled` reliably, and only
      // then look up progress from `/my-courses`, the one endpoint that
      // actually has it.
      final enrolled = await _fetchIsEnrolled(id);
      if (!enrolled) return Right(course);

      final progress = await _findProgress(id);
      return Right(course.copyWith(isEnrolled: true, progress: progress));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  Future<bool> _fetchIsEnrolled(int id) async {
    try {
      final response = await _api.get(ApiEndpoints.courseUnits(id));
      final data = response.data['data'];
      return data is Map && data['is_enrolled'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<double?> _findProgress(int id) async {
    try {
      final response = await _api.get(ApiEndpoints.courseMyProgress(id));
      final data = response.data['data'] as Map<String, dynamic>;
      final percentage = toIntOrNull(data['percentage']);
      return percentage != null ? percentage / 100 : null;
    } catch (_) {
      return null;
    }
  }

  @override
  ApiResult<void> activateCourse({
    required int courseId,
    required String cardCode,
  }) async {
    try {
      await _api.post(
        ApiEndpoints.activateCourse(courseId),
        data: {'card_code': cardCode},
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
