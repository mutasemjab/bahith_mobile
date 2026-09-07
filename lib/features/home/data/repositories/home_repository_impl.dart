import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_result.dart';
import '../../../../core/api/dio_error_mapper.dart';
import '../../domain/entities/home_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/home_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ApiClient _api;
  const HomeRepositoryImpl(this._api);

  @override
  ApiResult<HomeEntity> getHome() async {
    try {
      final response = await _api.get(ApiEndpoints.home);
      final data = response.data['data'] as Map<String, dynamic>;
      return Right(HomeModel.fromJson(data));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
