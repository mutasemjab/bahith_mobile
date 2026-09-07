import '../../../../core/api/api_result.dart';
import '../entities/banner_entity.dart';

abstract class BannerRepository {
  ApiResult<List<BannerEntity>> getBanners();
}
