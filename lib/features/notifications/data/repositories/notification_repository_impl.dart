import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_result.dart';
import '../../../../core/api/dio_error_mapper.dart';
import '../../../../core/utils/pagination.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final ApiClient _api;
  const NotificationRepositoryImpl(this._api);

  @override
  ApiResult<PaginatedResult<NotificationEntity>> getAll({
    required int page,
  }) async {
    try {
      final response = await _api.get(
        ApiEndpoints.notifications,
        queryParams: {'page': page},
      );
      final list = response.data['data'] as List<dynamic>;
      final items = list
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
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
  ApiResult<int> getUnreadCount() async {
    try {
      final response = await _api.get(
        ApiEndpoints.notifications,
        queryParams: {'page': 1},
      );
      return Right(response.data['unread_count'] ?? 0);
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<void> markRead(int id) async {
    try {
      await _api.post(ApiEndpoints.markNotificationRead(id));
      return const Right(null);
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<void> markAllRead() async {
    try {
      await _api.post(ApiEndpoints.markAllNotificationsRead);
      return const Right(null);
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<void> saveDeviceToken(String fcmToken) async {
    try {
      await _api.post(ApiEndpoints.deviceToken, data: {'fcm_token': fcmToken});
      return const Right(null);
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
