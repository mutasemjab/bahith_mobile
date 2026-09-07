import 'package:dartz/dartz.dart';

import '../../../../core/cubit/paginated_cubit.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/pagination.dart';
import '../../domain/entities/teacher_entity.dart';
import '../../domain/repositories/teacher_repository.dart';

class TeachersCubit extends PaginatedCubit<TeacherEntity> {
  final TeacherRepository _repository;
  String? _search;

  TeachersCubit(this._repository);

  void search(String query) {
    _search = query;
    loadFirstPage();
  }

  @override
  Future<Either<Failure, PaginatedResult<TeacherEntity>>> fetchPage(int page) =>
      _repository.getTeachers(page: page, search: _search);
}
