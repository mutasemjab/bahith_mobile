import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_result.dart';
import '../../../../core/api/dio_error_mapper.dart';
import '../../../../core/utils/pagination.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/note_repository.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  final ApiClient _api;
  const NoteRepositoryImpl(this._api);

  @override
  ApiResult<List<NoteEntity>> getAllNotes() async {
    try {
      final items = <NoteEntity>[];
      var page = 1;
      while (true) {
        final response = await _api.get(
          ApiEndpoints.educationalNotes,
          queryParams: {'page': page},
        );
        final list = response.data['data'] as List<dynamic>;
        items.addAll(
          list.map((e) => NoteModel.fromJson(e as Map<String, dynamic>)),
        );
        final meta = response.data['pagination'] != null
            ? PaginationMeta.fromJson(response.data['pagination'])
            : PaginationMeta.single(items.length);
        if (!meta.hasNextPage) break;
        page++;
      }
      return Right(items);
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
