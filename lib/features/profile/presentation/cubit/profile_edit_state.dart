import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/student_entity.dart';

abstract class ProfileEditState extends Equatable {
  const ProfileEditState();
  @override
  List<Object?> get props => [];
}

class ProfileEditIdle extends ProfileEditState {
  const ProfileEditIdle();
}

class ProfileEditSaving extends ProfileEditState {
  const ProfileEditSaving();
}

class ProfileEditSuccess extends ProfileEditState {
  final StudentEntity student;
  const ProfileEditSuccess(this.student);
  @override
  List<Object?> get props => [student];
}

class ProfileEditError extends ProfileEditState {
  final String message;
  final Map<String, dynamic>? fieldErrors;
  const ProfileEditError(this.message, {this.fieldErrors});
  @override
  List<Object?> get props => [message, fieldErrors];
}
