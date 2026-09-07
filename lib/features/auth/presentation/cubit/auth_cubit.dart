import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../conduct/domain/entities/conduct_document_entity.dart';
import '../../../conduct/domain/repositories/conduct_repository.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  final ConductRepository _conductRepository;
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;

  AuthCubit(
    this._repository,
    this._conductRepository,
    this._loginUseCase,
    this._registerUseCase,
  ) : super(const AuthInitial());

  /// Called once at splash to decide whether to route to home or login.
  Future<void> appStarted() async {
    final loggedIn = await _repository.isLoggedIn();
    if (!loggedIn) {
      emit(const AuthUnauthenticated());
      return;
    }
    final student = await _repository.cachedStudent();
    if (student == null) {
      emit(const AuthUnauthenticated());
      return;
    }
    await _resolveConductGate(student);
  }

  Future<void> login({
    required String nationalId,
    required String password,
  }) async {
    emit(const AuthLoading());
    final result = await _loginUseCase(
      nationalId: nationalId,
      password: password,
    );
    await result.fold<Future<void>>(
      (failure) async => emit(_toError(failure)),
      (data) => _resolveConductGate(data.student),
    );
  }

  Future<void> register({
    required String name,
    required String nationalId,
    required String password,
    required String passwordConfirmation,
    String? email,
    int? classId,
  }) async {
    emit(const AuthLoading());
    final result = await _registerUseCase(
      name: name,
      nationalId: nationalId,
      password: password,
      passwordConfirmation: passwordConfirmation,
      email: email,
      classId: classId,
    );
    await result.fold<Future<void>>(
      (failure) async => emit(_toError(failure)),
      (data) => _resolveConductGate(data.student),
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthUnauthenticated());
  }

  /// Called only after the blocking conduct screen receives a successful 201.
  Future<void> completeConductSignature() async {
    final current = state;
    if (current is! AuthConductRequired) return;

    try {
      await _conductRepository.markSignedLocallyFor(current.student.id);
    } catch (_) {
      // A local-cache failure must never undo an accepted server signature.
    }
    emit(AuthAuthenticated(current.student));
  }

  /// Refreshes the server-owned student record before a purchase. This
  /// upgrades cached sessions created before `app_account_token` was added,
  /// without asking the user or App Review to log out and sign in again.
  Future<String?> refreshAppAccountToken() async {
    final result = await _repository.refreshStudent();
    return result.fold((_) => null, (student) {
      emit(AuthAuthenticated(student));
      return student.appAccountToken;
    });
  }

  /// Deletes the server account, clears the local session, and lets the
  /// router move the student back to login. Returns an Arabic error message
  /// when the request fails so the confirmation dialog can remain visible.
  Future<String?> deleteAccount() async {
    final result = await _repository.deleteAccount();
    return result.fold((failure) => failure.message, (_) {
      emit(const AuthUnauthenticated());
      return null;
    });
  }

  /// Wired to [ApiClient.onUnauthorized] to react to expired tokens.
  void forceLogout() {
    if (state is AuthAuthenticated || state is AuthConductRequired) {
      emit(const AuthUnauthenticated());
    }
  }

  void updateStudent(StudentEntity student) => emit(AuthAuthenticated(student));

  AuthError _toError(Failure failure) {
    final fieldErrors = failure is ValidationFailure ? failure.errors : null;
    return AuthError(failure.message, fieldErrors: fieldErrors);
  }

  Future<void> _resolveConductGate(StudentEntity student) async {
    if (_conductRepository.isSignedLocallyFor(student.id)) {
      emit(AuthAuthenticated(student));
      return;
    }

    final result = await _conductRepository.getStatus();
    await result.fold<Future<void>>(
      (failure) async {
        if (failure is UnauthorizedFailure) {
          await _repository.logout();
          emit(const AuthUnauthenticated());
          return;
        }

        // Network/5xx (and other non-auth status-check failures) deliberately
        // fail open. Nothing is cached, so the next cold launch retries.
        emit(AuthAuthenticated(student));
      },
      (ConductStatusEntity status) async {
        if (status.signed) {
          try {
            await _conductRepository.markSignedLocallyFor(student.id);
          } catch (_) {
            // The server remains authoritative; proceed even if caching fails.
          }
          emit(AuthAuthenticated(student));
        } else {
          emit(AuthConductRequired(student));
        }
      },
    );
  }
}
