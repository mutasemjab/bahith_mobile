import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/repositories/announcement_repository.dart';

class AnnouncementDetailCubit extends Cubit<ResourceState<AnnouncementEntity>> {
  final AnnouncementRepository _repository;
  AnnouncementDetailCubit(this._repository) : super(const ResourceLoading());

  Future<void> load(int id) async {
    emit(const ResourceLoading());
    final result = await _repository.getById(id);
    result.fold(
      (failure) => emit(ResourceError(failure.message)),
      (data) => emit(ResourceLoaded(data)),
    );
  }
}
