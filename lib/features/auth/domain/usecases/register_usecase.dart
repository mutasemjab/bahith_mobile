import '../../../../core/api/api_result.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  ApiResult<AuthPayload> call({
    required String name,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? email,
    int? classId,
  }) => _repository.register(
    name: name,
    phone: phone,
    password: password,
    passwordConfirmation: passwordConfirmation,
    email: email,
    classId: classId,
  );
}
