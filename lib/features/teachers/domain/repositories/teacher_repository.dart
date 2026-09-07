import '../../../../core/api/api_result.dart';
import '../../../../core/utils/pagination.dart';
import '../entities/teacher_detail_entity.dart';
import '../entities/teacher_entity.dart';

abstract class TeacherRepository {
  ApiResult<PaginatedResult<TeacherEntity>> getTeachers({
    required int page,
    String? search,
  });
  ApiResult<TeacherDetailEntity> getTeacher(int id);
}
