import 'package:dartz/dartz.dart';

import '../../../../core/cubit/paginated_cubit.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/pagination.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationsCubit extends PaginatedCubit<NotificationEntity> {
  final NotificationRepository _repository;
  NotificationsCubit(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<NotificationEntity>>> fetchPage(
    int page,
  ) => _repository.getAll(page: page);
}
