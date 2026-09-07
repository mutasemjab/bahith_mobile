import '../../../../core/api/api_result.dart';
import '../../../../core/utils/pagination.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  ApiResult<PaginatedResult<NotificationEntity>> getAll({required int page});
  ApiResult<int> getUnreadCount();
  ApiResult<void> markRead(int id);
  ApiResult<void> markAllRead();
  ApiResult<void> saveDeviceToken(String fcmToken);
}
