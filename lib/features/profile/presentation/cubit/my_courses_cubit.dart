import 'package:dartz/dartz.dart';

import '../../../../core/cubit/paginated_cubit.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/pagination.dart';
import '../../../courses/domain/entities/course_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class MyCoursesCubit extends PaginatedCubit<CourseEntity> {
  final ProfileRepository _repository;
  MyCoursesCubit(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<CourseEntity>>> fetchPage(int page) =>
      _repository.getMyCourses(page: page);
}
