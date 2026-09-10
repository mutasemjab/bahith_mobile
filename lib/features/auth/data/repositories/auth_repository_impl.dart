import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/dio_error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/student_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final SecureStorage _storage;

  const AuthRepositoryImpl(this._remote, this._storage);

  @override
  Future<Either<Failure, AuthPayload>> login({
    required String nationalId,
    required String password,
  }) async {
    try {
      final deviceId = await _storage.getOrCreateDeviceId();
      final data = await _remote.login(
        nationalId: nationalId,
        password: password,
        deviceId: deviceId,
      );
      return Right(await _persist(data));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  Future<Either<Failure, AuthPayload>> register({
    required String name,
    required String nationalId,
    required String password,
    required String passwordConfirmation,
    String? email,
    int? classId,
  }) async {
    try {
      final deviceId = await _storage.getOrCreateDeviceId();
      final data = await _remote.register(
        name: name,
        nationalId: nationalId,
        password: password,
        passwordConfirmation: passwordConfirmation,
        deviceId: deviceId,
        email: email,
        classId: classId,
      );
      return Right(await _persist(data));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  Future<AuthPayload> _persist(Map<String, dynamic> data) async {
    final token = data['token'] as String;
    final studentJson = Map<String, dynamic>.from(data['student']);
    final student = StudentModel.fromJson(studentJson);

    await _storage.saveToken(token);
    await _storage.saveStudent(studentJson);

    return (token: token, student: student);
  }

  @override
  Future<Either<Failure, AuthPayload>> switchSibling(int siblingId) async {
    try {
      final data = await _remote.switchSibling(siblingId);
      return Right(await _persist(data));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remote.logout();
    } on DioException {
      // Ignore network failures on logout — clear local session regardless.
    } finally {
      await _storage.clear();
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await _remote.deleteAccount();
      await _storage.clear();
      return const Right(null);
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  Future<Either<Failure, StudentEntity>> refreshStudent() async {
    try {
      final studentJson = await _remote.profile();
      final student = StudentModel.fromJson(studentJson);
      await _storage.saveStudent(studentJson);
      return Right(student);
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  Future<bool> isLoggedIn() => _storage.hasToken();

  @override
  Future<StudentEntity?> cachedStudent() async {
    final json = await _storage.readStudent();
    if (json == null) return null;
    return StudentModel.fromJson(json);
  }
}
