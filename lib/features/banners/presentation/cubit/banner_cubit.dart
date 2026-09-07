import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/repositories/banner_repository.dart';

class BannerCubit extends Cubit<ResourceState<List<BannerEntity>>> {
  final BannerRepository _repository;
  BannerCubit(this._repository) : super(const ResourceLoading());

  Future<void> load() async {
    emit(const ResourceLoading());
    final result = await _repository.getBanners();
    result.fold(
      (failure) => emit(ResourceError(failure.message)),
      (banners) => emit(ResourceLoaded(banners)),
    );
  }
}
