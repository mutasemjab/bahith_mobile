import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../domain/entities/category_detail_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';

class CategoriesCubit extends Cubit<ResourceState<List<CategoryEntity>>> {
  final CategoryRepository _repository;
  CategoriesCubit(this._repository) : super(const ResourceLoading());

  Future<void> load() async {
    emit(const ResourceLoading());
    final result = await _repository.getCategories();
    result.fold(
      (failure) => emit(ResourceError(failure.message)),
      (categories) => emit(ResourceLoaded(categories)),
    );
  }
}

class CategoryDetailCubit extends Cubit<ResourceState<CategoryDetailEntity>> {
  final CategoryRepository _repository;
  CategoryDetailCubit(this._repository) : super(const ResourceLoading());

  Future<void> load(int id) async {
    emit(const ResourceLoading());
    final result = await _repository.getCategoryDetail(id);
    result.fold(
      (failure) => emit(ResourceError(failure.message)),
      (detail) => emit(ResourceLoaded(detail)),
    );
  }
}

class SubjectDetailCubit extends Cubit<ResourceState<SubjectDetailEntity>> {
  final CategoryRepository _repository;
  SubjectDetailCubit(this._repository) : super(const ResourceLoading());

  Future<void> load(int id) async {
    emit(const ResourceLoading());
    final result = await _repository.getSubjectDetail(id);
    result.fold(
      (failure) => emit(ResourceError(failure.message)),
      (detail) => emit(ResourceLoaded(detail)),
    );
  }
}
