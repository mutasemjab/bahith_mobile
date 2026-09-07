abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('لا يوجد اتصال بالإنترنت');
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure() : super('انتهت الجلسة، يرجى تسجيل الدخول');
}

class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;
  const ValidationFailure(super.message, {this.errors});

  String? firstErrorFor(String field) {
    final value = errors?[field];
    if (value is List && value.isNotEmpty) return value.first.toString();
    return null;
  }
}

class NotFoundFailure extends Failure {
  const NotFoundFailure() : super('العنصر غير موجود');
}
