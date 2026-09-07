import '../../../../core/api/api_result.dart';
import '../entities/home_entity.dart';

abstract class HomeRepository {
  ApiResult<HomeEntity> getHome();
}
