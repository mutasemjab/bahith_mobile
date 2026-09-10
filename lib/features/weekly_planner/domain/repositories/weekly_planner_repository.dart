import '../../../../core/api/api_result.dart';
import '../entities/weekly_planner_entity.dart';

abstract class WeeklyPlannerRepository {
  ApiResult<WeeklyPlannerEntity?> getLatest();
}
