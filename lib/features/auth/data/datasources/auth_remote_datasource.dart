import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
    required String deviceId,
  });

  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String deviceId,
    String? email,
    int? classId,
  });

  Future<void> logout();

  Future<void> deleteAccount();

  Future<Map<String, dynamic>> profile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _api;
  const AuthRemoteDataSourceImpl(this._api);

  @override
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
    required String deviceId,
  }) async {
    final response = await _api.post(
      ApiEndpoints.login,
      data: {
        // The deployed API still names its account-identifier field
        // `national_id`. New accounts use the phone number as that internal
        // identifier, so no separate government identifier is collected.
        'national_id': phone,
        'phone': phone,
        'password': password,
        'deviceId': deviceId,
      },
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
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
        // Compatibility bridge for the current backend contract. This is the
        // same phone number entered below, not a separate personal identifier.
        'national_id': phone,
        'phone': phone,
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
}
