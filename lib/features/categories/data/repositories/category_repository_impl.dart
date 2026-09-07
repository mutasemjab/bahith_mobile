import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_result.dart';
import '../../../../core/api/dio_error_mapper.dart';
import '../../../../core/utils/json_parsing.dart';
import '../../../courses/data/models/course_model.dart';
import '../../domain/entities/category_detail_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final ApiClient _api;
  const CategoryRepositoryImpl(this._api);

  @override
  ApiResult<List<CategoryEntity>> getCategories() async {
    try {
      final response = await _api.get(ApiEndpoints.categories);
      final data = response.data['data'] as List<dynamic>;
      return Right(
        data
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<CategoryDetailEntity> getCategoryDetail(int id) async {
    try {
      final response = await _api.get(ApiEndpoints.category(id));
      final data = response.data['data'] as Map<String, dynamic>;
      return Right(
        CategoryDetailEntity(
          category: CategoryModel.fromJson(unwrapResource(data, 'category')),
          children: (data['children'] as List<dynamic>? ?? [])
              .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList(),
          subjects: (data['subjects'] as List<dynamic>? ?? [])
              .map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<SubjectDetailEntity> getSubjectDetail(int id) async {
    try {
      final response = await _api.get(ApiEndpoints.subject(id));
      final data = response.data['data'] as Map<String, dynamic>;
      return Right(
        SubjectDetailEntity(
          subject: SubjectModel.fromJson(unwrapResource(data, 'subject')),
          courses: (data['courses'] as List<dynamic>? ?? [])
              .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
