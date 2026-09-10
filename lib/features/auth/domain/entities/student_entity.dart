import 'package:equatable/equatable.dart';

import 'sibling_entity.dart';

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

  /// Accounts linked to this one by an admin, for one-tap switching.
  final List<SiblingEntity> siblings;

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
    this.siblings = const [],
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
