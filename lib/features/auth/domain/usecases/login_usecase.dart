import '../../../../core/api/api_result.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  ApiResult<AuthPayload> call({
    required String phone,
    required String password,
  }) => _repository.login(phone: phone, password: password);
}
