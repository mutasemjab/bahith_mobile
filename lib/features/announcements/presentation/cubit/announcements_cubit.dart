import 'package:dartz/dartz.dart';

import '../../../../core/cubit/paginated_cubit.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/pagination.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/repositories/announcement_repository.dart';

class AnnouncementsCubit extends PaginatedCubit<AnnouncementEntity> {
  final AnnouncementRepository _repository;
  AnnouncementsCubit(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<AnnouncementEntity>>> fetchPage(
    int page,
  ) => _repository.getAll(page: page);
}
