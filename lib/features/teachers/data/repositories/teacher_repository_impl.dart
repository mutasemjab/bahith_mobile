import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_result.dart';
import '../../../../core/api/dio_error_mapper.dart';
import '../../../../core/utils/json_parsing.dart';
import '../../../../core/utils/pagination.dart';
import '../../../courses/data/models/course_model.dart';
import '../../domain/entities/teacher_detail_entity.dart';
import '../../domain/entities/teacher_entity.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../models/teacher_model.dart';

class TeacherRepositoryImpl implements TeacherRepository {
  final ApiClient _api;
  const TeacherRepositoryImpl(this._api);

  @override
  ApiResult<PaginatedResult<TeacherEntity>> getTeachers({
    required int page,
    String? search,
  }) async {
    try {
      final response = await _api.get(
        ApiEndpoints.teachers,
        queryParams: {
          'page': page,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      final list = response.data['data'] as List<dynamic>;
      final items = list
          .map((e) => TeacherModel.fromJson(e as Map<String, dynamic>))
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
  ApiResult<TeacherDetailEntity> getTeacher(int id) async {
    try {
      final response = await _api.get(ApiEndpoints.teacher(id));
      final data = response.data['data'] as Map<String, dynamic>;
      return Right(
        TeacherDetailEntity(
          teacher: TeacherModel.fromJson(unwrapResource(data, 'teacher')),
          courses: (data['courses'] as List<dynamic>? ?? [])
              .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
