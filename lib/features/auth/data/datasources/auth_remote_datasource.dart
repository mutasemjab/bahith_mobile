import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login({
    required String nationalId,
    required String password,
    required String deviceId,
  });

  Future<Map<String, dynamic>> register({
    required String name,
    required String nationalId,
    required String password,
    required String passwordConfirmation,
    required String deviceId,
    String? email,
    int? classId,
  });

  Future<void> logout();

  Future<void> deleteAccount();

  Future<Map<String, dynamic>> profile();

  Future<Map<String, dynamic>> switchSibling(int siblingId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _api;
  const AuthRemoteDataSourceImpl(this._api);

  @override
  Future<Map<String, dynamic>> login({
    required String nationalId,
    required String password,
    required String deviceId,
  }) async {
    final response = await _api.post(
      ApiEndpoints.login,
      data: {
        'national_id': nationalId,
        'password': password,
        'deviceId': deviceId,
      },
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String nationalId,
    required String password,
    required String passwordConfirmation,
    required String deviceId,
    String? email,
    int? classId,
  }) async {
    final response = await _api.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'national_id': nationalId,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'deviceId': deviceId,
        if (email != null && email.isNotEmpty) 'email': email,
        'class_id': ?classId,
      },
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  @override
  Future<void> logout() async {
    await _api.post(ApiEndpoints.logout);
  }

  @override
  Future<void> deleteAccount() async {
    await _api.delete(ApiEndpoints.deleteAccount);
  }

  @override
  Future<Map<String, dynamic>> profile() async {
    final response = await _api.get(ApiEndpoints.profile);
    return response.data['data'] as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> switchSibling(int siblingId) async {
    final response = await _api.post(ApiEndpoints.switchSibling(siblingId));
    return response.data['data'] as Map<String, dynamic>;
  }
}
