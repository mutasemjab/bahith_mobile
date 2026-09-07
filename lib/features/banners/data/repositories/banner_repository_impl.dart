import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_result.dart';
import '../../../../core/api/dio_error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/repositories/banner_repository.dart';
import '../models/banner_model.dart';

class BannerRepositoryImpl implements BannerRepository {
  final ApiClient _api;
  const BannerRepositoryImpl(this._api);

  @override
  ApiResult<List<BannerEntity>> getBanners() async {
    try {
      final response = await _api.get(ApiEndpoints.banners);
      dynamic rawData = response.data;
      if (rawData is Map) {
        rawData =
            rawData['data'] ??
            rawData['banners'] ??
            rawData['items'] ??
            rawData['banners_list'] ??
            rawData;
        if (rawData is Map) {
          rawData =
              rawData['banners'] ??
              rawData['items'] ??
              rawData['data'] ??
              rawData;
        }
      }

      if (rawData is List) {
        final banners =
            rawData
                .whereType<Map<String, dynamic>>()
                .map((e) => BannerModel.fromJson(e))
                .toList()
              ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
        return Right(banners);
      }
      return const Right([]);
    } catch (e) {
      if (e is DioException) {
        return Left(mapDioError(e));
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
