import 'package:equatable/equatable.dart';

import '../../domain/entities/student_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// App hasn't determined session status yet (splash screen).
class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final StudentEntity student;
  const AuthAuthenticated(this.student);
  @override
  List<Object?> get props => [student];
}

/// The token is valid, but this student must sign the active conduct document
/// before any authenticated app route can be opened.
class AuthConductRequired extends AuthState {
  final StudentEntity student;

  const AuthConductRequired(this.student);

  @override
  List<Object?> get props => [student];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  final Map<String, dynamic>? fieldErrors;
  const AuthError(this.message, {this.fieldErrors});
  @override
  List<Object?> get props => [message, fieldErrors];
}
