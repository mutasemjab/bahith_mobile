import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_result.dart';
import '../../../../core/api/dio_error_mapper.dart';
import '../../../../core/utils/json_parsing.dart';
import '../../../../core/utils/pagination.dart';
import '../../domain/entities/question_bank_entity.dart';
import '../../domain/repositories/question_bank_repository.dart';
import '../models/question_bank_model.dart';

class QuestionBankRepositoryImpl implements QuestionBankRepository {
  final ApiClient _api;
  const QuestionBankRepositoryImpl(this._api);

  @override
  ApiResult<PaginatedResult<QuestionBankEntity>> getAll({
    required int page,
    int? subjectId,
    String? search,
  }) async {
    try {
      final response = await _api.get(
        ApiEndpoints.questionBanks,
        queryParams: {
          'page': page,
          'subject_id': ?subjectId,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      final list = response.data['data'] as List<dynamic>;
      final items = list
          .map((e) => QuestionBankModel.fromJson(e as Map<String, dynamic>))
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
  ApiResult<QuestionBankEntity> getById(int id) async {
    try {
      final response = await _api.get(ApiEndpoints.questionBank(id));
      final data = response.data['data'] as Map<String, dynamic>;
      return Right(
        QuestionBankModel.fromJson(unwrapResource(data, 'question_bank')),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
