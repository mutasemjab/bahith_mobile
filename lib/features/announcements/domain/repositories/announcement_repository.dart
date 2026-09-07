import '../../../../core/api/api_result.dart';
import '../../../../core/utils/pagination.dart';
import '../entities/announcement_entity.dart';

abstract class AnnouncementRepository {
  ApiResult<PaginatedResult<AnnouncementEntity>> getAll({required int page});
  ApiResult<AnnouncementEntity> getById(int id);
}
