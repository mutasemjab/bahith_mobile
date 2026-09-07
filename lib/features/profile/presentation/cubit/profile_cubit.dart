import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileCubit extends Cubit<ResourceState<ProfileEntity>> {
  final ProfileRepository _repository;
  ProfileCubit(this._repository) : super(const ResourceLoading());

  Future<void> load() async {
    emit(const ResourceLoading());
    final result = await _repository.getProfile();
    result.fold(
      (failure) => emit(ResourceError(failure.message)),
      (profile) => emit(ResourceLoaded(profile)),
    );
  }
}
