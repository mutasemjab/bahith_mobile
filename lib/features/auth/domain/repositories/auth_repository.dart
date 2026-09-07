import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/student_entity.dart';

typedef AuthPayload = ({String token, StudentEntity student});

abstract class AuthRepository {
  Future<Either<Failure, AuthPayload>> login({
    required String nationalId,
    required String password,
  });

  Future<Either<Failure, AuthPayload>> register({
    required String name,
    required String nationalId,
    required String password,
    required String passwordConfirmation,
    String? email,
    int? classId,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> deleteAccount();

  Future<Either<Failure, StudentEntity>> refreshStudent();

  Future<bool> isLoggedIn();

  Future<StudentEntity?> cachedStudent();
}
