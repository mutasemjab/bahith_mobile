import 'package:baheth/core/api/api_result.dart';
import 'package:baheth/core/errors/failure.dart';
import 'package:baheth/features/auth/domain/entities/student_entity.dart';
import 'package:baheth/features/auth/domain/repositories/auth_repository.dart';
import 'package:baheth/features/auth/domain/usecases/login_usecase.dart';
import 'package:baheth/features/auth/domain/usecases/register_usecase.dart';
import 'package:baheth/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:baheth/features/auth/presentation/cubit/auth_state.dart';
import 'package:baheth/features/conduct/domain/entities/conduct_document_entity.dart';
import 'package:baheth/features/conduct/domain/repositories/conduct_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const student = StudentEntity(id: 7, name: 'طالب', isActive: true);

  AuthCubit buildCubit(FakeAuthRepository auth, FakeConductRepository conduct) {
    return AuthCubit(auth, conduct, LoginUseCase(auth), RegisterUseCase(auth));
  }

  test('cold launch blocks an unsigned authenticated student', () async {
    final auth = FakeAuthRepository(student: student);
    final conduct = FakeConductRepository(
      statusResult: const Right(
        ConductStatusEntity(signed: false, documentId: 1),
      ),
    );
    final cubit = buildCubit(auth, conduct);

    await cubit.appStarted();

    expect(cubit.state, isA<AuthConductRequired>());
    expect(conduct.statusCalls, 1);
    await cubit.close();
  });

  test('login also resolves the conduct gate before home access', () async {
    final auth = FakeAuthRepository(student: student);
    final conduct = FakeConductRepository(
      statusResult: const Right(
        ConductStatusEntity(signed: false, documentId: 1),
      ),
    );
    final cubit = buildCubit(auth, conduct);

    await cubit.login(nationalId: '0790000000', password: 'password123');

    expect(cubit.state, isA<AuthConductRequired>());
    await cubit.close();
  });

  test('a student-scoped local signature skips the status request', () async {
    final auth = FakeAuthRepository(student: student);
    final conduct = FakeConductRepository(
      locallySigned: true,
      statusResult: const Right(
        ConductStatusEntity(signed: false, documentId: 1),
      ),
    );
    final cubit = buildCubit(auth, conduct);

    await cubit.appStarted();

    expect(cubit.state, isA<AuthAuthenticated>());
    expect(conduct.statusCalls, 0);
    await cubit.close();
  });

  test('a server signature is cached and proceeds to home', () async {
    final auth = FakeAuthRepository(student: student);
    final conduct = FakeConductRepository(
      statusResult: const Right(
        ConductStatusEntity(signed: true, documentId: 1),
      ),
    );
    final cubit = buildCubit(auth, conduct);

    await cubit.appStarted();

    expect(cubit.state, isA<AuthAuthenticated>());
    expect(conduct.locallySigned, isTrue);
    await cubit.close();
  });

  test('a status network failure fails open without caching', () async {
    final auth = FakeAuthRepository(student: student);
    final conduct = FakeConductRepository(
      statusResult: const Left(NetworkFailure()),
    );
    final cubit = buildCubit(auth, conduct);

    await cubit.appStarted();

    expect(cubit.state, isA<AuthAuthenticated>());
    expect(conduct.locallySigned, isFalse);
    await cubit.close();
  });

  test('successful signing caches the flag and releases the gate', () async {
    final auth = FakeAuthRepository(student: student);
    final conduct = FakeConductRepository(
      statusResult: const Right(
        ConductStatusEntity(signed: false, documentId: 1),
      ),
    );
    final cubit = buildCubit(auth, conduct);
    await cubit.appStarted();

    await cubit.completeConductSignature();

    expect(conduct.locallySigned, isTrue);
    expect(cubit.state, isA<AuthAuthenticated>());
    await cubit.close();
  });

  test('an unauthorized status response clears the invalid session', () async {
    final auth = FakeAuthRepository(student: student);
    final conduct = FakeConductRepository(
      statusResult: const Left(UnauthorizedFailure()),
    );
    final cubit = buildCubit(auth, conduct);

    await cubit.appStarted();

    expect(cubit.state, isA<AuthUnauthenticated>());
    expect(auth.logoutCalls, 1);
    await cubit.close();
  });
}

class FakeAuthRepository implements AuthRepository {
  final StudentEntity student;
  int logoutCalls = 0;

  FakeAuthRepository({required this.student});

  @override
  Future<StudentEntity?> cachedStudent() async => student;

  @override
  Future<bool> isLoggedIn() async => true;

  @override
  Future<Either<Failure, AuthPayload>> login({
    required String nationalId,
    required String password,
  }) async => Right((token: 'token', student: student));

  @override
  Future<Either<Failure, AuthPayload>> register({
    required String name,
    required String nationalId,
    required String password,
    required String passwordConfirmation,
    String? email,
    int? classId,
  }) async => Right((token: 'token', student: student));

  @override
  Future<Either<Failure, void>> logout() async {
    logoutCalls++;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async => const Right(null);

  @override
  Future<Either<Failure, StudentEntity>> refreshStudent() async =>
      Right(student);
}

class FakeConductRepository implements ConductRepository {
  bool locallySigned;
  final Either<Failure, ConductStatusEntity> statusResult;
  int statusCalls = 0;

  FakeConductRepository({
    this.locallySigned = false,
    required this.statusResult,
  });

  @override
  bool isSignedLocallyFor(int studentId) => locallySigned;

  @override
  Future<void> markSignedLocallyFor(int studentId) async {
    locallySigned = true;
  }

  @override
  ApiResult<ConductStatusEntity> getStatus() async {
    statusCalls++;
    return statusResult;
  }

  @override
  ApiResult<ConductDocumentEntity> getDocument() async => const Right(
    ConductDocumentEntity(
      id: 1,
      titleAr: 'مدونة السلوك',
      titleEn: 'Code of Conduct',
      body: 'النص',
    ),
  );

  @override
  ApiResult<void> sign({required String guardianName}) async =>
      const Right(null);
}
