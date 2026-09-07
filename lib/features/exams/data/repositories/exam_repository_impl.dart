import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_result.dart';
import '../../../../core/api/dio_error_mapper.dart';
import '../../../../core/utils/json_parsing.dart';
import '../../../../core/utils/pagination.dart';
import '../../domain/entities/exam_entity.dart';
import '../../domain/repositories/exam_repository.dart';
import '../models/exam_model.dart';

class ExamRepositoryImpl implements ExamRepository {
  final ApiClient _api;
  const ExamRepositoryImpl(this._api);

  @override
  ApiResult<PaginatedResult<ExamEntity>> getExams({
    required int page,
    ExamFilters filters = const ExamFilters(),
  }) async {
    try {
      final response = await _api.get(
        ApiEndpoints.exams,
        queryParams: {'page': page, ...filters.toQuery()},
      );
      final list = response.data['data'] as List<dynamic>;
      final items = list
          .map((e) => ExamModel.fromJson(e as Map<String, dynamic>))
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
  ApiResult<ExamEntity> getExam(int id) async {
    try {
      final response = await _api.get(ApiEndpoints.exam(id));
      final data = response.data['data'] as Map<String, dynamic>;
      return Right(ExamModel.fromJson(unwrapResource(data, 'exam')));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<int> startExam(int id) async {
    try {
      final response = await _api.post(ApiEndpoints.startExam(id));
      final data = response.data['data'] as Map<String, dynamic>;
      return Right(data['attempt_id']);
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<ExamResultEntity> submitAttempt({
    required int attemptId,
    required Map<int, int> answers,
  }) async {
    try {
      final response = await _api.post(
        ApiEndpoints.submitAttempt(attemptId),
        data: {
          'answers': answers.entries
              .map((e) => {'question_id': e.key, 'option_id': e.value})
              .toList(),
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return Right(ExamResultModel.fromJson(data, attemptId: attemptId));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
