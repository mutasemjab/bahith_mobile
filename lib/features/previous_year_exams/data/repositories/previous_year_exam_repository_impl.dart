import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_result.dart';
import '../../../../core/api/dio_error_mapper.dart';
import '../../../../core/models/subject_ref.dart';
import '../../../../core/utils/json_parsing.dart';
import '../../../../core/utils/pagination.dart';
import '../../domain/entities/previous_year_exam_entity.dart';
import '../../domain/repositories/previous_year_exam_repository.dart';
import '../models/previous_year_exam_model.dart';

class PreviousYearExamRepositoryImpl implements PreviousYearExamRepository {
  final ApiClient _api;
  const PreviousYearExamRepositoryImpl(this._api);

  @override
  ApiResult<PaginatedResult<PreviousYearExamEntity>> getAll({
    required int page,
    int? classId,
    int? subjectId,
    int? year,
    String? search,
  }) async {
    try {
      final response = await _api.get(
        ApiEndpoints.previousYearExams,
        queryParams: {
          'page': page,
          'class_id': ?classId,
          'subject_id': ?subjectId,
          'year': ?year,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      final list = response.data['data'] as List<dynamic>;
      final items = list
          .map((e) => PreviousYearExamModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final meta = response.data['pagination'] != null
          ? PaginationMeta.fromJson(response.data['pagination'])
          : PaginationMeta.single(items.length);
      return Right(PaginatedResult(items: items, meta: meta));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<PreviousYearExamEntity> getById(int id) async {
    try {
      final response = await _api.get(ApiEndpoints.previousYearExam(id));
      final data = response.data['data'] as Map<String, dynamic>;
      return Right(
        PreviousYearExamModel.fromJson(
          unwrapResource(data, 'previous_year_exam'),
        ),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<List<SubjectRef>> getSubjects({required int classId}) async {
    try {
      final subjects = <int, SubjectRef>{};
      var page = 1;
      while (true) {
        final response = await _api.get(
          ApiEndpoints.previousYearExams,
          queryParams: {'page': page, 'class_id': classId},
        );
        final list = response.data['data'] as List<dynamic>;
        for (final e in list) {
          final exam = PreviousYearExamModel.fromJson(
            e as Map<String, dynamic>,
          );
          if (exam.subjectId != null && exam.subjectName != null) {
            subjects[exam.subjectId!] = SubjectRef(
              id: exam.subjectId!,
              name: exam.subjectName!,
            );
          }
        }
        final meta = response.data['pagination'] != null
            ? PaginationMeta.fromJson(response.data['pagination'])
            : PaginationMeta.single(list.length);
        if (!meta.hasNextPage) break;
        page++;
      }
      return Right(subjects.values.toList());
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
