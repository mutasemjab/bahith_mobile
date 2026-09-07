import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_result.dart';
import '../../../../core/api/dio_error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/conduct_document_entity.dart';
import '../../domain/repositories/conduct_repository.dart';
import '../models/conduct_document_model.dart';

class ConductRepositoryImpl implements ConductRepository {
  final ApiClient _api;
  final SecureStorage _storage;

  const ConductRepositoryImpl(this._api, this._storage);

  @override
  ApiResult<ConductDocumentEntity> getDocument() async {
    try {
      final response = await _api.get(ApiEndpoints.conduct);
      final data = Map<String, dynamic>.from(response.data['data'] as Map);
      return Right(ConductDocumentModel.fromJson(data));
    } on DioException catch (error) {
      return Left(mapDioError(error));
    } catch (_) {
      return const Left(ServerFailure('تعذر قراءة مدونة السلوك.'));
    }
  }

  @override
  ApiResult<ConductStatusEntity> getStatus() async {
    try {
      final response = await _api.get(ApiEndpoints.conductStatus);
      final data = Map<String, dynamic>.from(response.data['data'] as Map);
      return Right(ConductStatusModel.fromJson(data));
    } on DioException catch (error) {
      return Left(mapDioError(error));
    } catch (_) {
      return const Left(ServerFailure('تعذر التحقق من حالة مدونة السلوك.'));
    }
  }

  @override
  ApiResult<void> sign({required String guardianName}) async {
    try {
      await _api.post(
        ApiEndpoints.conductSign,
        data: {'guardian_name': guardianName.trim()},
      );
      return const Right(null);
    } on DioException catch (error) {
      return Left(mapDioError(error));
    }
  }

  @override
  bool isSignedLocallyFor(int studentId) =>
      _storage.isConductSignedFor(studentId);

  @override
  Future<void> markSignedLocallyFor(int studentId) =>
      _storage.markConductSignedFor(studentId);
}
