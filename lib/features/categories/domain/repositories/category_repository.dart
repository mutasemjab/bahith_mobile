import '../../../../core/api/api_result.dart';
import '../entities/category_detail_entity.dart';
import '../entities/category_entity.dart';

abstract class CategoryRepository {
  ApiResult<List<CategoryEntity>> getCategories();
  ApiResult<CategoryDetailEntity> getCategoryDetail(int id);
  ApiResult<SubjectDetailEntity> getSubjectDetail(int id);
}
