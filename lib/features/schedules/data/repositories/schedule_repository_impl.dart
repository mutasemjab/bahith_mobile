import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_result.dart';
import '../../../../core/api/dio_error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../models/schedule_model.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ApiClient _api;
  const ScheduleRepositoryImpl(this._api);

  @override
  ApiResult<ScheduleEntity?> getClassSchedule() =>
      _fetch(ApiEndpoints.classSchedule);

  @override
  ApiResult<ScheduleEntity?> getExamSchedule() =>
      _fetch(ApiEndpoints.examSchedule);

  Future<Either<Failure, ScheduleEntity?>> _fetch(String path) async {
    try {
      final response = await _api.get(path);
      return Right(ScheduleModel.fromJsonOrNull(response.data['data']));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
