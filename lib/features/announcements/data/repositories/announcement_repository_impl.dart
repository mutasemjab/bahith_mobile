import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_result.dart';
import '../../../../core/api/dio_error_mapper.dart';
import '../../../../core/utils/json_parsing.dart';
import '../../../../core/utils/pagination.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement_model.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final ApiClient _api;
  const AnnouncementRepositoryImpl(this._api);

  @override
  ApiResult<PaginatedResult<AnnouncementEntity>> getAll({
    required int page,
  }) async {
    try {
      final response = await _api.get(
        ApiEndpoints.announcements,
        queryParams: {'page': page},
      );
      final list = response.data['data'] as List<dynamic>;
      final items = list
          .map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>))
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
  ApiResult<AnnouncementEntity> getById(int id) async {
    try {
      final response = await _api.get(ApiEndpoints.announcement(id));
      final data = response.data['data'] as Map<String, dynamic>;
      return Right(
        AnnouncementModel.fromJson(unwrapResource(data, 'announcement')),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
