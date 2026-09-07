import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_result.dart';
import '../../../../core/api/dio_error_mapper.dart';
import '../../../../core/utils/json_parsing.dart';
import '../../../../core/utils/pagination.dart';
import '../../domain/entities/worksheet_entity.dart';
import '../../domain/repositories/worksheet_repository.dart';
import '../models/worksheet_model.dart';

class WorksheetRepositoryImpl implements WorksheetRepository {
  final ApiClient _api;
  const WorksheetRepositoryImpl(this._api);

  @override
  ApiResult<PaginatedResult<WorksheetEntity>> getAll({
    required int page,
    int? subjectId,
    int? year,
    String? search,
  }) async {
    try {
      final response = await _api.get(
        ApiEndpoints.worksheets,
        queryParams: {
          'page': page,
          'subject_id': ?subjectId,
          'year': ?year,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      final list = response.data['data'] as List<dynamic>;
      final items = list
          .map((e) => WorksheetModel.fromJson(e as Map<String, dynamic>))
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
  ApiResult<WorksheetEntity> getById(int id) async {
    try {
      final response = await _api.get(ApiEndpoints.worksheet(id));
      final data = response.data['data'] as Map<String, dynamic>;
      return Right(WorksheetModel.fromJson(unwrapResource(data, 'worksheet')));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
