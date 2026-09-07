import 'package:dartz/dartz.dart';

import '../../../../core/cubit/paginated_cubit.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/pagination.dart';
import '../../domain/entities/question_bank_entity.dart';
import '../../domain/repositories/question_bank_repository.dart';

class QuestionBanksCubit extends PaginatedCubit<QuestionBankEntity> {
  final QuestionBankRepository _repository;
  String? searchQuery;
  int? subjectId;

  QuestionBanksCubit(this._repository);

  void search(String query) {
    searchQuery = query;
    loadFirstPage();
  }

  @override
  Future<Either<Failure, PaginatedResult<QuestionBankEntity>>> fetchPage(
    int page,
  ) =>
      _repository.getAll(page: page, subjectId: subjectId, search: searchQuery);
}
