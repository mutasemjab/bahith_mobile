import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_result.dart';
import '../../../../core/api/dio_error_mapper.dart';
import '../../domain/entities/weekly_planner_entity.dart';
import '../../domain/repositories/weekly_planner_repository.dart';
import '../models/weekly_planner_model.dart';

class WeeklyPlannerRepositoryImpl implements WeeklyPlannerRepository {
  final ApiClient _api;
  const WeeklyPlannerRepositoryImpl(this._api);

  @override
  ApiResult<WeeklyPlannerEntity?> getLatest() async {
    try {
      // Goes through the shared ApiClient, which attaches the Bearer token
      // automatically — this endpoint now requires authentication.
      final response = await _api.get(ApiEndpoints.weeklyPlanner);
      return Right(WeeklyPlannerModel.fromJsonOrNull(response.data['data']));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
