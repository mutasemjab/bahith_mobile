import 'package:dio/dio.dart';

import '../errors/failure.dart';

/// Maps a [DioException] to a domain [Failure], honoring the API's
/// `{status, message, errors}` error envelope.
Failure mapDioError(DioException e) {
  if (e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout) {
    return const NetworkFailure();
  }

  final statusCode = e.response?.statusCode;
  final data = e.response?.data;
  final message = (data is Map && data['message'] is String)
      ? data['message'] as String
      : 'حدث خطأ، حاول مجدداً';

  if (statusCode == 401) return const UnauthorizedFailure();
  if (statusCode == 404) return const NotFoundFailure();
  if (statusCode == 422) {
    final errors = (data is Map && data['errors'] is Map)
        ? Map<String, dynamic>.from(data['errors'] as Map)
        : null;
    return ValidationFailure(message, errors: errors);
  }
  return ServerFailure(message);
}
