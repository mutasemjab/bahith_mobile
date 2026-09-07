import 'package:dartz/dartz.dart';

import '../../../../core/cubit/paginated_cubit.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/pagination.dart';
import '../../domain/entities/exam_attempt_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class MyExamsCubit extends PaginatedCubit<ExamAttemptEntity> {
  final ProfileRepository _repository;
  MyExamsCubit(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<ExamAttemptEntity>>> fetchPage(
    int page,
  ) => _repository.getMyExams(page: page);
}
