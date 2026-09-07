import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_edit_state.dart';

class ProfileEditCubit extends Cubit<ProfileEditState> {
  final ProfileRepository _repository;
  final AuthCubit _authCubit;

  ProfileEditCubit(this._repository, this._authCubit)
    : super(const ProfileEditIdle());

  Future<void> save(UpdateProfilePayload payload) async {
    emit(const ProfileEditSaving());
    final result = await _repository.updateProfile(payload);
    result.fold(
      (failure) {
        final fieldErrors = failure is ValidationFailure
            ? failure.errors
            : null;
        emit(ProfileEditError(failure.message, fieldErrors: fieldErrors));
      },
      (student) {
        _authCubit.updateStudent(student);
        emit(ProfileEditSuccess(student));
      },
    );
  }
}
