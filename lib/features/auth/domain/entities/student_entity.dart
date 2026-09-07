import 'package:equatable/equatable.dart';

class StudentEntity extends Equatable {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? className;
  final int? classId;
  final String? gender;
  final String? dateOfBirth;
  final String? nationality;

  /// Permanent server UUID used to derive a student-and-course StoreKit token.
  final String? appAccountToken;
  final bool isActive;

  const StudentEntity({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.avatar,
    this.className,
    this.classId,
    this.gender,
    this.dateOfBirth,
    this.nationality,
    this.appAccountToken,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    avatar,
    className,
    phone,
    email,
    appAccountToken,
  ];
}
