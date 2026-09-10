import '../../../../core/api/api_result.dart';
import '../entities/schedule_entity.dart';

abstract class ScheduleRepository {
  /// The class schedule image for the logged-in student's own class — the
  /// API resolves the class server-side, no `class_id` is sent.
  ApiResult<ScheduleEntity?> getClassSchedule();

  /// The exam schedule image for the logged-in student's own class.
  ApiResult<ScheduleEntity?> getExamSchedule();
}
